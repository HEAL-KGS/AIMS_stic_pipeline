# STIC-QAQC_01_TidyData_CalibrateData.R
# First AIMS STIC pipeline script
# Iterates tidy_hobo_data over a folder of raw STIC CSVs
# Then, saves the tidy files in the correct AIMS format:
# startDate-endDate_siteID_rType_rep_sublocation
# Example: 20220403-20220620_OKM01_STIC_00_HS.csv
# After data is tidied, this script also iterates get_calibration and 
# apply_calibration to produce a folder of tidied CSVs with the 
# calibrated SpC column, then saves with the same naming scheme

# load STICr and tidyverse
library(tidyverse)
library(STICr)

# Create list of file paths to iterate over 
data_dir <- "raw_csv_01"
fs::dir_ls(data_dir)
stic_files <- fs::dir_ls(file.path(data_dir), regexp = "\\.csv$")

# loop for applying tidy_hobo_data and naming correctly 
for(i in 1:length(stic_files)) {
  # get information about file and sensor
  path_to_raw <- stic_files[i]
  
  # isolate SN from full file path
  logger_no <- gsub(".csv", "", path_to_raw) %>% 
    gsub("_STIC", "", .) %>% 
    gsub("raw_02/", "", .) %>% 
    str_sub(-8, -1)   
  
  # bring in index of SNs and site names 
  sn_index <- read_csv("STIC_SN_index_01.csv") %>% 
    drop_na()
  
  # create site name var for use in saving later 
  site_name <- sn_index$location[sn_index$sn == logger_no]
  
  # apply tidy_hobo_data to files
  path_to_tidy <- file.path(data_dir, "tidy", paste0(site_name, "_tidy.csv")) # do we need this
  stic_data_tidy <- tidy_hobo_data(infile = stic_files[i])
  
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
    add_column(rep = "00", .before = 5) %>% 
    add_column(sublocation = subloc, .before = 6) %>% 
    add_column(SN = logger_no, .before = 7)
  
  # save in correct format, i.e., 
  # startDate-endDate_siteID_rType_rep_sublocation
  # 20220403-20220620_OKM01_STIC_00_HS.csv
  tidy_save_dir <- "tidy"
  write_csv(stic_data_tidy, file.path(tidy_save_dir, 
                                            paste0(start_date, "-", end_date, "_", site_name, "_",
                                                   "STIC_00_", subloc, ".csv")))
  
  # status update for tidying
  print(paste0("saved tidy STIC # ", i, " of ", length(stic_files), " at ", Sys.time()))
  
  # Now begin calibrating and re-saving the tidied CSVs:
  
  # bring in calibration points dataframe
  stic_calibrations <- read_csv("stic_calibration.csv") 
  
  # get and apply calibration
  logger_calibration <- subset(stic_calibrations, sn == logger_no)
  
  # Create column of NAs for SpC if there is no calibration info for that logger
  if (dim(logger_calibration)[1] == 0) {
    stic_data_calibrated <- stic_data_tidy %>% 
      mutate(SpC = NA)
  } else {
    calibration_fit <- get_calibration(logger_calibration)
    stic_data_calibrated <- apply_calibration(stic_data_tidy, calibration_fit)
  }
  
  # Save in correct format
  calibrated_save_dir <- "calibrated"
  write_csv(stic_data_calibrated, file.path(calibrated_save_dir, 
                                      paste0(start_date, "-", end_date, "_", site_name, "_",
                                             "STIC_00_", subloc, ".csv")))
  
  # status update for calibrating
  print(paste0("saved calibrated STIC # ", i, " of ", length(stic_files), " at ", Sys.time()))
}
