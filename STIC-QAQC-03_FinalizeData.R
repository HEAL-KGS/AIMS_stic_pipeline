# After last step, data is tidied and in AIMS format with one file per site
# This script will bring it in, apply calibration and classification
# Then save in AIMS format to be housed in the "final" folder on Drive

# load STICr and Tidyverse
library(tidyverse)
library(STICr)

data_dir <- "merged_calibrated"
fs::dir_ls(data_dir)
stic_files <- fs::dir_ls(file.path(data_dir), regexp = "\\.csv$")

i <- 1

for(i in 1:length(stic_files)) {
  # get information about file and sensor
  path_to_raw <- stic_files[i]
  siteID <- 
    gsub(".csv", "", path_to_raw) %>%
    gsub("merged_calibrated/", "", .)

  
  stic_data_classified <- classify_wetdry(stic_data_calibrated, classify_var = "spc", threshold = 50)
  
  
  # figure out start and end date for each file
  start_date <- min(stic_data_tidy$datetime) %>% 
    lubridate::date() %>% 
    as.character() %>% 
    gsub("-", "", .)
  
  end_date <- max(stic_data_tidy$datetime) %>% 
    lubridate::date() %>% 
    as.character() %>% 
    gsub("-", "", .)
  

  # classify wetdry and save
  stic_data_classified <- classify_wetdry(stic_data_calibrated, classify_var = "spc", threshold = 50)
  write_csv(stic_data_classified, file.path(data_dir, "classified", 
                                            paste0(site_name, "_", start_date, "-", end_date, "_classified.csv")))
  
  # status update
  print(paste0("Completed STIC # ", i, " of ", length(stic_files), " at ", Sys.time()))
  
}
