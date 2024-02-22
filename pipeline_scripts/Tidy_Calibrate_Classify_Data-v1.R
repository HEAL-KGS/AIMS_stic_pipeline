# STIC-QAQC_01_TidyData_CalibrateData.R
# First AIMS STIC pipeline script
# Iterates tidy_hobo_data over a folder of raw STIC CSVs
# Then, saves the tidy files in the correct AIMS format:
# startDate-endDate_siteID_rType_rep_sublocation
# Example: 20220403-20220620_OKM01_STIC_00_HS.csv
# After data is tidied, this script also iterates get_calibration and 
# apply_calibration, and classify_wetdry to produce a folder of tidied CSVs with the 
# calibrated SpC column, then saves with the same naming scheme

# reinstall STICr if necessary 
#library(devtools)
#devtools::install_github("HEAL-KGS/STICr")

# load STICr and tidyverse
library(tidyverse)
library(STICr)

# bring in STIC serial number and location index
# Need to change path for each run
sn_index <- read_csv("KNZ_STIC_metadata/KNZ_STIC_sn_indices/KNZ_STIC_sn_index_202207_202301.csv") 

# Cut off record after pull time from STIC_sn_index df
sn_index <- sn_index %>% 
  mutate(pull_datetime = lubridate::mdy_hm(pull_datetime, tz = "US/Central")) %>% 
  mutate(datetime_utc = with_tz(pull_datetime, "UTC")) %>% 
  mutate(rounded_datetime = lubridate::floor_date(datetime_utc, unit = "15 mins")) %>% 
  mutate(pull_date = lubridate::date(rounded_datetime))

classified_save_dir <- "KNZ_STIC_classified"

# bring in calibration points dataframe
stic_calibrations <- read_csv("KNZ_STIC_metadata/KNZ_STIC_calibrations/KNZ_STIC_calibrations_202105_202301.csv") 

# Create list of file paths to iterate over 
data_dir <- "KNZ_STIC_raw/KNZ_STIC_202207_202301_raw"
fs::dir_ls(data_dir)
stic_files <- list.files(file.path(data_dir), pattern = "\\.csv$")

# loop for applying tidy_hobo_data and naming correctly 
for(i in 1:length(stic_files)) {
  # get information about file and sensor
  path_to_raw <- stic_files[i]
  
  # isolate SN from full file path
  logger_no <- gsub(".csv", "", path_to_raw) %>% 
    gsub("_STIC", "", .) %>% 
    str_sub(-8, -1)   

  # create site name var for use in saving later 
  site_name <- sn_index$location[sn_index$sn == logger_no]
  
  # apply tidy_hobo_data to files
  stic_data_tidy <- tidy_hobo_data(infile = file.path(data_dir, stic_files[i]), convert_utc = FALSE) 

  if (sum(str_detect(sn_index$location, site_name)) < 1) {
    
    last_date <- lubridate::date(max(stic_data_tidy$datetime, na.rm = TRUE))

    stic_data_tidy <- stic_data_tidy %>% 
      filter(datetime < last_date)
    
    start_date <- min(stic_data_tidy$datetime, na.rm = TRUE) %>%
      lubridate::date() %>%
      as.character() %>%
      gsub("-", "", .)
    
    end_date <- max(stic_data_tidy$datetime, na.rm = TRUE) %>%
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
    
  } else {
    
    stic_data_tidy <- stic_data_tidy %>% 
      filter(datetime < sn_index$rounded_datetime[sn_index$location == site_name])
    
    start_date <- min(stic_data_tidy$datetime, na.rm = TRUE) %>%
      lubridate::date() %>%
      as.character() %>%
      gsub("-", "", .)
    
    end_date <- max(stic_data_tidy$datetime, na.rm = TRUE) %>%
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
  }
 
  # Now begin calibrating and re-saving the tidied CSVs:
  # get and apply calibration
  logger_calibration <- subset(stic_calibrations, sn == logger_no) %>% 
    rename(sensor = sn) %>% 
    select(standard, condUncal)
  
  # Create column of NAs for SpC if there is no calibration info for that logger
  if (dim(logger_calibration)[1] == 0) {
    stic_data_calibrated <- stic_data_tidy %>% 
      mutate(SpC = NA, outside_std_range = NA)
    
    stic_data_classified <- STICr::classify_wetdry(stic_data = stic_data_calibrated, classify_var =  "condUncal",
                                                   threshold = 1000, "absolute")
  } else {
    calibration <- get_calibration(logger_calibration, method = "linear")
    just_spc <- predict(object = calibration, newdata = stic_data_tidy)
    stic_data_tidy$SpC <- just_spc
    stic_data_calibrated <- stic_data_tidy
    
    # Classify into binary wet/dry data frame
    stic_data_classified <- STICr::classify_wetdry(stic_data = stic_data_calibrated, classify_var =  "SpC",
                                                   threshold = 200, "absolute")
    # Create QAQC column that identifies when calibrated value is
    # outside of the range of the QAQC standard
    stic_data_classified$outside_std_range <- 
      dplyr::if_else(stic_data_calibrated$SpC >= max(logger_calibration$standard, na.rm = TRUE), "O", "")
  }
  
  # also need to make a sublocation variable to use when saving
  if (str_sub(site_name, -1, -1) == 1) {
    subloc <- "HS"
  } else {
    subloc <- "LS"
  }

  # Save in correct format
  write_csv(stic_data_classified, file.path(classified_save_dir, 
                                      paste0(start_date, "-", end_date, "_", site_name,  "_",
                                             "STIC_00_", subloc, ".csv")))
  # status update for calibrating
  print(paste0("saved calibrated and classified STIC # ", i, " of ", length(stic_files), " at ", Sys.time()))
}
