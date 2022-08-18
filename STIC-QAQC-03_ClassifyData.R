# After last step, data is tidied and calibrated in AIMS format with
# one file per site.
# This script will bring it in and classify it 
# Then will save in merged_classified folder

# load STICr and Tidyverse
library(tidyverse)
library(STICr)

# Make list of files in the merged_calibrated folder
hobo_logger_files <- list.files(path = "merged_calibrated")

# Loop to read them all all, run through classify function, then save back
# With site name in merged_classified folder
for(csv_file in hobo_logger_files){
  
  logger_record <- read_csv(paste0("merged_calibrated/", csv_file))
  
  print(paste("Read in file", csv_file, "to process."))
  
  processed <- classify_wetdry(logger_record, classify_var = "SpC", method = "absolute", threshold = 200)
  
  
  write_csv(processed, file = paste0("merged_classified/", csv_file))
  
  print("Finished processing and writing new file to merged_classified folder")
}
