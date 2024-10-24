## XX_UpdateQAQCflags.R
# This script reads in files from a folder and changes the QAQC flags as follows:
#  - "N" --> "C" = calibration results in negative value
#  - "A" --> "D" = deviation/anomaly from moving window approach
#  - "O" (unchanged) = outside range of calibration standards
#  - NA = no QAQC flag 
# This needs to be done to all the data processed by Chris (KNZ, YMR, and OKA prior to Jan 2023)
# The reason is that for some STICs, we were getting "N" and "A" flags so it looked like "NA"
#
# Checklist:
#  [x] KNZ - completed 8/27/2024 by SZ - "G:/.shortcut-targets-by-id/1KSx3E1INg4hQNlHWYnygPi41k_ku66fz/Track 2 AIMS/QA QCed Data/STIC/GP/KNZ_STIC_QAQC"
#  [X] YMR - completed 8/27/2024 by SZ - "G:/.shortcut-targets-by-id/1KSx3E1INg4hQNlHWYnygPi41k_ku66fz/Track 2 AIMS/Data [working files]/Core datasets (as defined by implementation plan)/Approach 1_sensors and STICs/STICs/Great_Plains/YMR_STIC_QAQC"
#  [X] OKA - completed 8/27/2024 by SZ - "G:/.shortcut-targets-by-id/1KSx3E1INg4hQNlHWYnygPi41k_ku66fz/Track 2 AIMS/QA QCed Data/STIC/GP/OKA_STIC_QAQC"

# update this to the folder holding the old QAQC data with the incorrect flags
setwd("G:/.shortcut-targets-by-id/1KSx3E1INg4hQNlHWYnygPi41k_ku66fz/Track 2 AIMS/Data [working files]/Core datasets (as defined by implementation plan)/Approach 1_sensors and STICs/STICs/Great_Plains/YMR_STIC_QAQC")

all_files <- list.files(pattern = "*.csv")

for (i in 1:length(all_files)){
  df_in <- read_csv(all_files[i], col_types = "cTccdccdcdccc")
  
  df_in$QAQC <- str_replace(df_in$QAQC, "N", "C")
  df_in$QAQC <- str_replace(df_in$QAQC, "A", "D")
  
  write_csv(df_in, all_files[i])
}
