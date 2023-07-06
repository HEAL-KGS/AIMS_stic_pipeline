# Script to iterate generation of markdown document for folder of files 
# September 2022

library(rmarkdown)
library(stringr)

# directory is the folder with all your data files in it
list_of_files = list.files('YMR_merged_QAQC', '.csv')

f <- 1

for (f in 1:length(list_of_files)) {
  # Get the names of the sensors alone, for making file names
  sensor_name <- list_of_files[f]
  
  sensor_name <- sensor_name %>% 
    gsub(".csv", "", .)
  
  outputname <- paste0('analysis_of_',sensor_name,'.pdf')
  
  full_file <- paste0('merged_classified/', sensor_name, '.csv')

  render("pipeline_scripts/analysis_file.rmd", output_file = paste0('YMR_markdown_docs/', outputname), params = list(datafile = full_file))
}
