# STIC_04_GenerateQAQCgraphs.R

# load control script
source("STIC_00_ControlScript.R")

# load in metadata 
metadata <- read_csv(path_observations)

# Create list of file paths to iterate over 
dir_save_plots <- "KNZ_QAQC_graphs"
fs::dir_ls(dir_data_QAQC)
stic_files <- list.files(file.path(dir_data_QAQC), pattern = "\\.csv$")

# loop for applying tidy_hobo_data and naming correctly 
for(i in 1:length(stic_files)) {
  
  # load csv file
  STIC_file <- read_csv(file.path(dir_data_QAQC, stic_files[i]))
  
  site_name <- STIC_file$siteID[1]
  
  # subset meta for just that site
  meta_sub <- metadata |> 
    filter(Location == site_name) |> 
    mutate(datetime = lubridate::mdy_hm(datetime))
  
  STIC_file_long <- STIC_file |> 
    select(datetime, condUncal, tempC, SpC, wetdry) |> 
    pivot_longer(cols = c(condUncal, tempC, SpC), names_to = "variable")
  
  # make as single faceted plot 
  ggplot(STIC_file_long, aes(x = datetime, y = value, color = wetdry)) + 
    geom_point() + 
    facet_wrap(~variable, scales = "free_y", ncol = 1) +
    geom_vline(xintercept = subset(meta_sub, wet_dry == "wet")$datetime, color = "blue") +
    geom_vline(xintercept = subset(meta_sub, wet_dry == "dry")$datetime, color = "red") +
    labs(title = site_name) + 
    theme(plot.title = element_text(hjust = 0.5)) + 
    theme_bw() + 
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),
          panel.background = element_rect(colour = "black", size = 1)) + 
    theme(axis.text = element_text(size = 12),
          axis.title = element_text(size = 14))
  
  ggsave(file.path(dir_save_plots, paste0(site_name, ".png")))

}
  

