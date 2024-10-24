## XX_UpdateWetdryThres.R
# This script updates QAQCed data with a new wetdry threshold based on an accuracy assessment.
# The original condUncal threshold used was 10000 (data processed prior to 10/24/2024).
# This script changes the threshold to condUncal of 700
# 
# The 'D' QAQC flag also needs to be updated since it is based on an anomaly window.
# We will also take this opportunity to change the anomaly size and window size - 
#   for 15 min data, set deviation_size to 4 (1 hr) and  window_wize to 96 (1 day)

# load packages
library(STICr)
library(tidyverse)

# set directory of data - should be location of output of STIC_02_QAQCdata.R script
setwd("G:/.shortcut-targets-by-id/1KSx3E1INg4hQNlHWYnygPi41k_ku66fz/Track 2 AIMS/Data [working files]/Core datasets (as defined by implementation plan)/Approach 1_sensors and STICs/STICs/Great_Plains/KNZ_STIC_QAQC")

# old and new threshold
old_thres <- 10000
new_thres <- 700

# list of files
stic_file_list <- fs::dir_ls(regexp = "\\.csv$")
for (s in stic_file_list){
  # testing: s <- stic_file_list[122]
  
  ## load data
  df_s <- read_csv(s)
  
  ## step 1: reclassify
  # inspection
  # table(df_s$wetdry)
  # table(df_s$condUncal > old_thres)
  # table(df_s$condUncal > new_thres)
  
  # update classification
  df_s$wetdry[df_s$condUncal > new_thres] <- "wet"
  # table(df_s$wetdry)
  # ggplot(df_s, aes(x = datetime, y = condUncal, color = wetdry)) + geom_point() + geom_hline(yintercept = c(old_thres, new_thres), linetype = "dashed") + theme_bw()

  ## step 2: update moving window deviation QAQC flag
  # remove old "D" flag
  # count: sum(grepl("D", df_s$QAQC, fixed = TRUE))
  df_s$QAQC <- gsub("D", "", df_s$QAQC)
  
  # redo moving window analysis
  QAQCnew <- qaqc_stic_data(df_s, spc_neg_correction = F, inspect_deviation = T, 
                                 deviation_size = 4, window_size = 96)
  # count:sum(grepl("D", QAQCnew$QAQC, fixed = TRUE))
  
  # which have D in new QAQC column?
  D_new <- which(grepl("D", QAQCnew$QAQC, fixed = TRUE))
  
  # add D to old column
  df_s$QAQC[D_new] <- paste0(df_s$QAQC[D_new], "D")
  # count: sum(grepl("D", df_s$QAQC, fixed = TRUE))
  
  # write output file
  write_csv(df_s, s)
  
}