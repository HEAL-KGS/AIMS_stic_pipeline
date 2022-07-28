# Getting the tidy files in the right format
# startDate-endDate_siteID_rType_rep_sublocation
# 20220403-20220620_OKM01_STIC_00_HS.csv

# load STICr and tidyverse
library(tidyverse)
library(STICr)

# Create list of file paths to iterate over 
data_dir <- "raw_csv_v1"
fs::dir_ls(data_dir)
stic_files <- fs::dir_ls(file.path(data_dir), regexp = "\\.csv$")

# loop for applying tidy_hobo_data and naming correctly 
for(i in 1:length(stic_files)) {
  # get information about file and sensor
  path_to_raw <- stic_files[i]
  
  # isolate SN from full filepath
  logger_no <- gsub(".csv", "", path_to_raw) %>% 
    gsub("_STIC", "", .) %>% 
    gsub("raw_v1/", "", .) %>% 
    str_sub(-8, -1)   
  
  # bring in index of SNs and site names 
  sn_index <- read_csv("STIC_SN_index_v1.csv")
  
  # create site name var for use in saving later 
  site_name <- sn_index$location[sn_index$sn == logger_no]
  
  # apply tidy_hobo_data to files
  path_to_tidy <- file.path(data_dir, "tidy", paste0(site_name, "_tidy.csv"))
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
    add_column(SN = logger_no, .before = 7) %>% 
    rename(condUncal = conductivity_uncal) %>% 
    rename(tempC = temperature)
  
  # save in correct format, i.e., 
  # startDate-endDate_siteID_rType_rep_sublocation
  # 20220403-20220620_OKM01_STIC_00_HS.csv
  write_csv(stic_data_tidy, file.path(data_dir, "tidy", 
                                            paste0(start_date, "-", end_date, "_", site_name, "_",
                                                   "STIC_00_", sublocation, ".csv")))
  # status update
  print(paste0("saved tidy STIC # ", i, " of ", length(stic_files), " at ", Sys.time()))
  
}
