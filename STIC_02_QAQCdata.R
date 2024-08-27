# STIC_02_QAQCdata.R
# This is a slow step which requires manual input for each STIC.

# load control script
source("STIC_00_ControlScript.R")

# load in metadata 
metadata <- 
  read_csv(path_observations) |> 
  mutate(datetime = mdy_hm(datetime))

# Create list of file paths to iterate over 
#fs::dir_ls(dir_data_classified)
stic_files <- list.files(file.path(dir_data_classified), pattern = "\\.csv$")

for(i in 1:length(stic_files)){
  
  logger_record <- read.csv(file = file.path(dir_data_classified, stic_files[i]))
  
  logger_record["outside_std_range"][is.na(logger_record["outside_std_range"])] <- ""
  
  qaqc_stic <- qaqc_stic_data(
    logger_record,
    spc_neg_correction = TRUE,
    inspect_classification = TRUE,
    anomaly_size = 5,
    window_size = 1000,
    concatenate_flags = TRUE
  ) |> 
    mutate(datetime = as_datetime(datetime))
  
  site_name <- qaqc_stic$siteID[1]
  
  start_date <- 
    min(qaqc_stic$datetime, na.rm = TRUE) |>
    lubridate::date() |>
    as.character() |>
    str_replace_all("-", "")
  
  end_date <- max(qaqc_stic$datetime, na.rm = TRUE) |>
    lubridate::date() |>
    as.character() |>
    str_replace_all("-", "")
  
  # extract metadata within +/- 5 days of start date
  site_metadata <- 
    subset(metadata, 
           str_detect(Location, str_replace(site_name, "_DUP", "_1")) &  # if it is a DUP, look for _1
           datetime >= ymd(start_date) - days(5) &
             datetime <= ymd(end_date) + days(5))
  
  # prep for plotting
  qaqc_stic_long <-
    qaqc_stic |> 
    dplyr::select(datetime, condUncal, tempC, SpC, wetdry, QAQC) |> 
    pivot_longer(cols = c(condUncal, tempC, SpC))
  
  # plot
  qaqc_plot <-
    ggplot(qaqc_stic_long, aes(x = datetime, y = value, color = wetdry)) +
    geom_point() +
    facet_wrap(~name, scales = "free_y", ncol = 1) +
    theme(legend.position = "bottom") +
    geom_vline(xintercept = subset(site_metadata, wet_dry == "wet")$datetime, color = "blue") +
    geom_vline(xintercept = subset(site_metadata, wet_dry == "dry")$datetime, color = "red") +
    geom_vline(xintercept = subset(site_metadata, wet_dry == "damp")$datetime, color = "green") +
    geom_vline(xintercept = subset(site_metadata, str_detect(wet_dry, "ic"))$datetime, color = "black") +
    labs(title = site_name)
  
  if (dim(site_metadata)[1] > 0){
    qaqc_table <- tableGrob(site_metadata)
  } else {
    qaqc_table <- tableGrob(data.frame(data = "none"))
  }
  
  (qaqc_plot + qaqc_table) +
    plot_layout(ncol = 1, heights = c(5, 1))
  
  ggsave(file.path(dir_plots_qaqc, paste0(site_name, "_QAQC_", start_date, "-", end_date, ".png")),
         width = 240, height = 190, units = "mm")
  
  # ask for QAQC decision
  # rating criteria: https://docs.google.com/document/d/14-qSH7_fj3CqxwJJr9kdaid0gozqLP1mWWJ_7gaSTaQ/edit
  qaqc_rating <- menu(c("Excellent", "Good", "Fair", "Poor"), title = paste0(site_name, ", Quality Rating?"))
  
  # add qualitative rating
  if (qaqc_rating == 1){
    qaqc_stic$qual_rating <- "excellent"
  } else if (qaqc_rating == 2){
    qaqc_stic$qual_rating <- "good"
  } else if (qaqc_rating == 3){
    qaqc_stic$qual_rating <- "fair"
  } else if (qaqc_rating == 4){
    qaqc_stic$qual_rating <- "poor" 
  } else {
    stop("Error in qual_rating")
  }
  
  # Save in correct format
  write_csv(qaqc_stic, file = file.path(dir_data_qaqc, paste0(start_date, "-", end_date,
                                                              "_", site_name,  "_", "STIC_00", ".csv")))
  
  print(paste0("Finished processing and writing new file ", stic_files[i], ", i = ", i))
}