# STIC_03_QAQCdata.R
#

# load control script
source("STIC_00_ControlScript.R")

# Create list of file paths to iterate over 
fs::dir_ls(dir_data_combined)
stic_files <- list.files(file.path(dir_data_combined), pattern = "\\.csv$")

stic_files <- list.files(path = dir_data_combined)

for(i in 1:length(stic_files)){
  
  logger_record <- read.csv(file = file.path(dir_data_combined, stic_files[i]))

  logger_record["outside_std_range"][is.na(logger_record["outside_std_range"])] <- ""
  
  qaqc_stic <- qaqc_stic_data(
    logger_record,
    spc_neg_correction = TRUE,
    inspect_classification = TRUE,
    anomaly_size = 5,
    window_size = 1000,
    concatenate_flags = TRUE
  )
  
  site_name <- qaqc_stic$siteID[1]
  
  start_date <- min(qaqc_stic$datetime, na.rm = TRUE) |>
    lubridate::date() |>
    as.character() |>
    gsub("-", "", .)
  
  end_date <- max(qaqc_stic$datetime, na.rm = TRUE) |>
    lubridate::date() |>
    as.character() |>
    gsub("-", "", .)
  
  # Save in correct format
  write_csv(qaqc_stic, file = file.path(paste0(start_date, "-", end_date,
                                     "_", site_name,  "_", "STIC_00", ".csv")))

  print(paste("Finished processing and writing new file", stic_files[i], "."))
}