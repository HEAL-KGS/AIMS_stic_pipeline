# Qualitative_Rating.R
# Script to apply AIMS qualitative rating system
# using metadata sheet
# and QAQC data

# load tidyverse and STICr
library(tidyverse)
library(STICr)

# Get list of file paths for tidy folder
data_dir <- "KNZ_merged_QAQC_202105_202201"
fs::dir_ls(data_dir)
stic_file_list <- fs::dir_ls(data_dir, regexp = "\\.csv$")

### using the map_dfr function to loop in individual
stic_data_qaqc <- stic_file_list %>% 
  map_dfr(read_csv) %>% 
  mutate(siteID = as_factor(siteID))

# bring in YMR metadata
metadata <- read_csv("KNZ_STIC_metadata/KNZ_STIC_QAQC_metadata/KNZ_STIC_QAQC_metadata.csv")


# make posixct sequence for comparing run time of STIC
download_period <- seq(lubridate::ymd_hm("2021-7-15 0:00"), lubridate::ymd_hm("2023-3-25 0:00"), by = "15 mins")

x <- nrow(stic_data_qaqc) / length(download_period)


# Now making qualitative rating column
stic_data_qaqc$rating <- "Poor"

if ( nrow(stic_data_qaqc) / length(download_period) >= 0.75 & ) {
  
  stic_data_classified$rating <- "Fair"
  
} else if () {
  
  stic_data_classified$rating <- "Good" 
  
} else {
  
  stic_data_classified$rating <- "Excellent"
  
}



