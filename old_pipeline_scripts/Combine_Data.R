# STIC-QAQC_02_CombineData.R
# Script to row bind tidied and/or calibrated STIC files by the same site
# All tidied and/or calibrated STIC files to date are in the directory
# called "tidy" or the directory called "calibrated"

# load tidyverse
library(tidyverse)

# Get list of file paths for KNZ_STIC_classified folder
data_dir <- "YMR_STIC_classified"
fs::dir_ls(data_dir)
stic_file_list <- fs::dir_ls(data_dir, regexp = "\\.csv$")

### using the map_dfr function to loop in individual
# files from the folder, then row bind
stic_data_classified <- stic_file_list %>% 
  map_dfr(read_csv) %>% 
  mutate(siteID = as_factor(siteID))

save_dir <- "YMR_STIC_combined"

stic_data_classified %>% 
  group_split(siteID) %>% 
  walk(~write_csv(.x, file.path(save_dir, paste0(.x$siteID[1], ".csv"))))
