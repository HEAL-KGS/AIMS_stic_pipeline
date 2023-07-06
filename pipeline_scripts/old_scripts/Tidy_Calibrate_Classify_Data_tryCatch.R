# STIC-QAQC_01_TidyData_CalibrateData.R
# First AIMS STIC pipeline script
# Iterates tidy_hobo_data over a folder of raw STIC CSVs
# Then, saves the tidy files in the correct AIMS format:
# startDate-endDate_siteID_rType_rep_sublocation
# Example: 20220403-20220620_OKM01_STIC_00_HS.csv
# After data is tidied, this script also iterates get_calibration and 
# apply_calibration to produce a folder of tidied CSVs with the 
# calibrated SpC column, then saves with the same naming scheme

# reinstall STICr if necessary 
# library(devtools)
# devtools::install_github("HEAL-KGS/STICr")

# load STICr and tidyverse
library(tidyverse)
library(STICr)

# bring in STIC serial number and location index
# Need to change path for each run
sn_index <- read_csv("KNZ_STIC_metadata/KNZ_STIC_sn_indices/KNZ_STIC_sn_index_202201_202207.csv") %>% 
  drop_na()

classified_save_dir <- "KNZ_STIC_classified"

# bring in calibration points dataframe
stic_calibrations <- read_csv("KNZ_STIC_metadata/KNZ_STIC_calibrations/KNZ_STIC_calibrations_202105_202301.csv") 

# Create list of file paths to iterate over 
data_dir <- "KNZ_STIC_raw/KNZ_STIC_202201_202207_raw"
fs::dir_ls(data_dir)
stic_files <- list.files(file.path(data_dir), pattern = "\\.csv$")

# loop for applying tidy_hobo_data and naming correctly 
for(i in 1:length(stic_files)) {
  
  tryCatch({
  
  # get information about file and sensor
  path_to_raw <- stic_files[i]
  
  # isolate SN from full file path
  logger_no <- gsub(".csv", "", path_to_raw) %>% 
    gsub("_STIC", "", .) %>% 
    str_sub(-8, -1)   

  # create site name var for use in saving later 
  site_name <- sn_index$location[sn_index$sn == logger_no]
  
  # apply tidy_hobo_data to files
  stic_data_tidy <- tidy_hobo_data(infile = file.path(data_dir, stic_files[i]))
  
  # figure out start and end date for each file for saving
  start_date <- min(stic_data_tidy$datetime) %>% 
    lubridate::date() %>% 
    as.character() %>% 
    gsub("-", "", .)
  
  end_date <- max(stic_data_tidy$datetime) %>% 
    lubridate::date() %>% 
    as.character() %>% 
    gsub("-", "", .)
  
  # also need to make a sublocation variable to use when saving 
  if (str_sub(site_name, -1, -1) == 1) {
    subloc <- "HS"
  } else {
    subloc <- "LS"
  }
  
  # make the additional columns per AIMS format
  stic_data_tidy <- stic_data_tidy %>% 
    add_column(project = "AIMS", .before = 1) %>% 
    add_column(siteID = site_name, .before = 3) %>% 
    add_column(rType = "STIC", .before = 4) %>% 
    add_column(rep =  paste0(start_date, "-", end_date)) %>% 
    add_column(sublocation = subloc, .before = 6) %>% 
    add_column(SN = logger_no, .before = 7)
  
  # Now begin calibrating and re-saving the tidied CSVs:

  # get and apply calibration
  logger_calibration <- subset(stic_calibrations, sn == logger_no) %>% 
    rename(sensor = sn) %>% 
    select(standard, condUncal)
  
  # Create column of NAs for SpC if there is no calibration info for that logger
  if (dim(logger_calibration)[1] == 0) {
    stic_data_calibrated <- stic_data_tidy %>% 
      mutate(SpC = NA)
  } else {
    calibration <- get_calibration(logger_calibration, method = "linear")
    just_spc <- predict(object = calibration, newdata = stic_data_tidy)
    stic_data_tidy$SpC <- just_spc
    stic_data_calibrated <- stic_data_tidy
    
    # Create QAQC column that identifies when calibrated value is
    # outside of the range of the QAQC standard
    stic_data_calibrated$outside_std_range <- 
      dplyr::if_else(stic_data_calibrated$SpC >= max(logger_calibration$standard), "O", "")
  }
  
  # Classify into binary wet/dry data frame
  stic_data_classified <- STICr::classify_wetdry(stic_data = stic_data_calibrated, classify_var =  "SpC",
                                                 threshold = 200, "absolute")
  
  # Save in correct format
  write_csv(stic_data_classified, file.path(classified_save_dir, 
                                      paste0(start_date, "-", end_date, "_", site_name, "_",
                                             "STIC_00_", subloc, ".csv")))
  
  # status update for calibrating
  print(paste0("saved calibrated and classified STIC # ", i, " of ", length(stic_files), " at ", Sys.time()))
  
  }, error=function(e){})
  
}
