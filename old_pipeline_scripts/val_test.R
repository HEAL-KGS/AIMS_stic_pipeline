# try to run validate function on ENM05

library(tidyverse)
library(STICr)


YMR_STIC_metadata <- read_csv("YMR_STIC_metadata/YMR_STIC_QAQC_metadata/YMR_STIC_metadata.csv")

ENM05 <- read_csv("YMR_merged_QAQC/ENM05.csv")

data_validation_confusion_matrix <- 
  validate_stic_data(stic_data = ENM05, field_observations = YMR_STIC_metadata)


