# STIC_02_CombineData.R
# Script to row bind tidied and/or calibrated STIC files by the same site
# All tidied and/or calibrated STIC files to date are in the directory
# called "tidy" or the directory called "calibrated"

# load control script
source("STIC_00_ControlScript.R")

# Get list of file paths from the folder
fs::dir_ls(dir_data_classified)
stic_file_list <- fs::dir_ls(dir_data_classified, regexp = "\\.csv$")

### using the map_dfr function to loop in individual
# files from the folder, then row bind
stic_data_classified <- stic_file_list |> 
  map_dfr(read_csv) |> 
  mutate(siteID = as_factor(siteID))

stic_data_classified |> 
  group_split(siteID) |> 
  walk(~write_csv(.x, file.path(dir_data_combined, paste0(.x$siteID[1], ".csv"))))
