# STIC-QAQC_04_FinalizeData
# Script to apply out first pass QAQC in the form of a column with multiple 
# letter codes (like USGS or NEON data)
# I will do this by bringing in all the merged data with map functions, 
# then applying the QAQC 
# Then splitting by site again 

# load tidyverse and STICr
library(tidyverse)
library(STICr)

# Get list of file paths for tidy folder
data_dir <- "merged_classified"
fs::dir_ls(data_dir)
stic_file_list <- fs::dir_ls(data_dir, regexp = "\\.csv$")

### using the map_dfr function to loop in individual
# files from the folder, then row bind
stic_data_classified <- stic_file_list %>% 
  map_dfr(read_csv) %>% 
  mutate(siteID = as_factor(siteID))

# Now start doing QAQC steps
# First, put in watershed col: KNZ, YMR, OKA 
stic_data_classified$watershed <- "KNZ"

if (str_sub(stic_data_classified$siteID, 1, 2) == "EN") {
  
  stic_data_classified$watershed <- "YMR"
  
} else if (str_sub(stic_data_classified$siteID, 1, 2) == "OK") {
  
  stic_data_classified$watershed <- "OKA" 
  
} else {
  
  stic_data_classified$watershed <- "KNZ"
  
  }
  

# Deal with negative spc values (maybe move to previous script) 
stic_data_classified <- stic_data_classified %>% 
  mutate(SpC = if_else(
    condition = SpC <= -1,
    true = 0, 
    false = SpC)) %>% 
  mutate(SpC_neg = if_else(
    condition = SpC == 0,
    true = "A", 
    false = "" ))

# concatenate the two QAQC columns with col codes: "A" for negative Spc; 
# "B" for Spc value outside of standard range

stic_data_classified$outside_std_range <- "B"

stic_data_classified$QAQC <- 
  stringr::str_c(stic_data_classified$SpC_neg, '', stic_data_classified$outside_std_range)

stic_data_classified <- stic_data_classified %>% 
  select(- outside_std_range) %>% 
  select(- SpC_neg)

# Save in merged_qaqc folder
save_dir <- "merged_qaqc"

stic_data_tidy %>% 
  group_split(siteID) %>% 
  walk(~write_csv(.x, file.path(save_dir, paste0(.x$siteID[1], ".csv"))))

