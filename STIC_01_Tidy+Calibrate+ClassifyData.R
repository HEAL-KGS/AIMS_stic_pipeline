## STIC_01_Tidy+Calibrate+ClassifyData.R
# First AIMS STIC pipeline script
# Iterates tidy_hobo_data over a folder of raw STIC CSVs
# Then, saves the tidy files in the correct AIMS format:
# startDate-endDate_siteID_rType_rep_sublocation
# Example: 20220403-20220620_OKM01_STIC_00_HS.csv
# After data is tidied, this script also iterates get_calibration and 
# apply_calibration, and classify_wetdry to produce a folder of tidied CSVs with the 
# calibrated SpC column, then saves with the same naming scheme

# load control script
source("STIC_00_ControlScript.R")

# make plots?
plots <- F

# bring in STIC serial number and location index
# Need to change path for each run
sn_index_in <- read_csv(path_sn_index) 

# Cut off record after pull time from STIC_sn_index df
sn_index <- 
  sn_index_in |> 
  mutate(pull_datetime = lubridate::mdy_hm(pull_datetime, tz = "US/Central")) |> 
  mutate(datetime_utc = with_tz(pull_datetime, "UTC") - hours(1)) |> 
  mutate(rounded_datetime = lubridate::floor_date(datetime_utc, unit = "15 mins")) |> 
  mutate(pull_date = lubridate::date(rounded_datetime)) |> 
  subset(!is.na(sn))

# bring in calibration points dataframe
path_calibration_data <- file.path(path_root, "Calibrations", "Calibrations_All.csv") # path to Calibrations_All.csv file
stic_calibrations <- read_csv(path_calibration_data) 

# Create list of file paths to iterate over 
fs::dir_ls(dir_data_raw)
stic_files <- list.files(file.path(dir_data_raw), pattern = "\\.csv$")

# loop for applying tidy_hobo_data and naming correctly 
for(i in 1:length(stic_files)) {
  # get information about file and sensor
  path_to_raw <- stic_files[i]
  
  # isolate SN from full file path
  logger_no <- 
    str_replace(path_to_raw, ".csv", "") |> 
    str_replace("_STIC", "") |>  # some files have "_STIC" in name, some don't
    str_replace("_raw", "") |>  # some files have "_raw" in name, some don't
    str_sub(-8, -1)   

  # create site name var for use in saving later 
  site_name <- sn_index$location[sn_index$sn == logger_no]
  if (length(site_name) == 0) site_name <- "Unknown"
  
  # apply tidy_hobo_data to files
  stic_data_tidy_in <- tidy_hobo_data(infile = file.path(dir_data_raw, stic_files[i]), convert_utc = TRUE) 

  if (sum(str_detect(sn_index$location, site_name)) < 1) {
    warning(paste0(logger_no, " not found in sn_index"))
    
    print(paste0("missing SN index STIC # ", i, " of ", length(stic_files), " at ", Sys.time()))
    
  } else {
    
    stic_data_tidy <- 
      stic_data_tidy_in |> 
      filter(datetime < sn_index$rounded_datetime[sn_index$location == site_name])
    
    start_date <- 
      min(stic_data_tidy$datetime, na.rm = TRUE) |>
      lubridate::date() |>
      as.character() |>
      str_replace_all("-", "")
    
    end_date <- 
      max(stic_data_tidy$datetime, na.rm = TRUE) |>
      lubridate::date() |>
      as.character() |>
      str_replace_all("-", "")
    
    # also need to make a sublocation variable to use when saving
    if (str_sub(site_name, -1, -1) == 1) {
      subloc <- "HS"
    } else {
      subloc <- "LS"
    }
    
    # make the additional columns per AIMS format
    stic_data_tidy_out <- 
      stic_data_tidy |>
      subset(is.finite(condUncal)) |>
      add_column(project = "AIMS", .before = 1) |>
      add_column(siteID = site_name, .before = 3) |>
      add_column(rType = "STIC", .before = 4) |>
      add_column(rep =  paste0(start_date, "-", end_date)) |>
      add_column(sublocation = subloc, .before = 6) |>
      add_column(SN = logger_no, .before = 7)
    
    # Now begin calibrating and re-saving the tidied CSVs:
    # get and apply calibration
    logger_calibration <- 
      subset(stic_calibrations, sn == logger_no) |> 
      rename(sensor = sn) |> 
      select(standard, condUncal)
    
    # Create column of NAs for SpC if there is no calibration info for that logger
    if (dim(logger_calibration)[1] == 0) {
      stic_data_calibrated <- 
        stic_data_tidy_out |> 
        mutate(SpC = NA, outside_std_range = NA)
      
      stic_data_classified <- STICr::classify_wetdry(stic_data = stic_data_calibrated, classify_var =  "condUncal",
                                                     threshold = 10000, "absolute")
    } else {
      calibration <- get_calibration(logger_calibration, method = "linear")
      stic_data_calibrated <- stic_data_tidy_out
      stic_data_calibrated$SpC <- predict(object = calibration, newdata = stic_data_calibrated)
      
      # Classify into binary wet/dry data frame
      stic_data_classified <- STICr::classify_wetdry(stic_data = stic_data_calibrated, classify_var =  "condUncal",
                                                     threshold = 10000, "absolute")
      # Create QAQC column that identifies when calibrated value is
      # outside of the range of the QAQC standard
      stic_data_classified$outside_std_range <- 
        dplyr::if_else(stic_data_calibrated$SpC >= max(logger_calibration$standard, na.rm = TRUE), "O", "")
    }
    
    # peek at data
    if (plots){
      ggplot(stic_data_classified, aes(x = datetime, y = condUncal, color = wetdry)) + geom_point() + labs(title = paste0(logger_no, ", ", site_name))
      ggplot(stic_data_classified, aes(x = datetime, y = log10(condUncal), color = wetdry)) + geom_point() + labs(title = paste0(logger_no, ", ", site_name))
      ggplot(stic_data_classified, aes(x = datetime, y = SpC, color = wetdry)) + geom_point() + labs(title = paste0(logger_no, ", ", site_name))
      ggplot(stic_data_classified, aes(x = datetime, y = tempC, color = wetdry)) + geom_point() + labs(title = paste0(logger_no, ", ", site_name))
    }
    
    # Save in correct format
    write_csv(stic_data_classified, file.path(dir_data_classified, 
                                              paste0(start_date, "-", end_date, "_", site_name,  "_",
                                                     "STIC_00_", subloc, ".csv")))
    
    # status update for calibrating
    print(paste0("saved calibrated and classified STIC # ", i, " of ", length(stic_files), " at ", Sys.time()))
  }
 
}
