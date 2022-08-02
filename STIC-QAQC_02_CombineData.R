# Script to row bind tidied STIC files by the same site
# All tidied STIC files to date are in the directory called "tidy"

# load tidyverse
library(tidyverse)

# Get list of file paths
data_dir <- "tidy"
fs::dir_ls(data_dir)
stic_file_list <- fs::dir_ls(data_dir, regexp = "\\.csv$")

### using the map_dfr function to loop in individual
# files from the folder, then row bind
stic_data_tidy <- stic_file_list %>% 
  map_dfr(read_csv) %>% 
  mutate(siteID = as_factor(siteID))

save_dir <- "merged_tidy"

stic_data_tidy %>% 
  group_split(siteID) %>% 
  walk(~write_csv(.x, file.path(save_dir, paste0(.x$siteID[1], ".csv"))))
