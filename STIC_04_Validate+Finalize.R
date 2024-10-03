## STIC_04_Validate+Finalize.R
# This script is intended to load all the STIC data and do two things:
#  (1) Validate it via comparison to field observations.
#  (2) Save it in the final AIMS preferred output format (separate file for each site and year).

# load control script
source("STIC_00_ControlScript.R")

# load all STIC data
stic_file_list <- fs::dir_ls(dir_data_qaqc, regexp = "\\.csv$")
df_all_raw <- bind_rows(lapply(stic_file_list, read_csv, col_types = "cTccnccncnccc"))


# Step 1: Compare to field observations, create validation plots --------

# load in metadata 
metadata <- 
  read_csv(path_observations) |> 
  mutate(datetime = mdy_hm(datetime, tz = "America/Chicago")) |> 
  rename(wetdry = wet_dry) |> 
  dplyr::select(Location, datetime, wetdry, SpC) |> 
  unique() |> 
  subset(!is.na(wetdry) | !is.na(SpC))

# convert to UTC to match STIC measurements
metadata$datetime <- as.POSIXct(metadata$datetime, tz = "UTC")

# validation
df_validate <- validate_stic_data(stic_data = df_all_raw, 
                                  field_observations = metadata, 
                                  max_time_diff = 60,
                                  join_cols = c("siteID" = "Location"),
                                  get_SpC = T)

# plot confusion matrix
df_confusion <- 
  df_validate |> 
  group_by(wetdry_obs, wetdry_STIC) |> 
  summarize(count = n()) |> 
  subset(wetdry_obs != "damp")

accuracy <- 
  (df_confusion$count[df_confusion$wetdry_obs=="wet" & df_confusion$wetdry_STIC=="wet"] +
     df_confusion$count[df_confusion$wetdry_obs=="dry" & df_confusion$wetdry_STIC=="dry"])/sum(df_confusion$count)

p_accuracy <-
  ggplot(df_confusion, aes(x = wetdry_STIC, y = wetdry_obs, fill = count)) +
  geom_raster() +
  geom_text(aes(label = count)) +
  scale_x_discrete(name = "Classified STIC wetdry", expand = c(0,0)) +
  scale_y_discrete(name = "Observed wetdry", expand = c(0,0)) +
  scale_fill_gradient(name = "Count", low = "gray85", high = "#0082c8", 
                      limits = c(0, max(df_confusion$count))) +
  labs(title = "KNZ STIC accuracy assessment", 
       subtitle = paste0("Overall accuracy = ", round(100*accuracy, 1), "%"))
ggsave(file.path(dir_data_final, "..", paste0(watershed, "_AllSTICs_ClassificationAccuracy.png")),
       p_accuracy, width = 120, height = 95, units = "mm")

# SpC comparison
SpC_min <- min(c(df_validate$SpC_obs, df_validate$SpC_STIC), na.rm = T)
SpC_max <- max(c(df_validate$SpC_obs, df_validate$SpC_STIC), na.rm = T)

p_SpC <-
  ggplot(df_validate, aes(x = SpC_obs, y = SpC_STIC)) +
  geom_abline(intercept = 0, slope = 1, color = "gray65") +
  geom_point() +
  scale_x_continuous(limits = c(SpC_min, SpC_max)) +
  scale_y_continuous(limits = c(SpC_min, SpC_max)) +
  theme_bw()
ggsave(file.path(dir_data_final, "..", paste0(watershed, "_AllSTICs_SpCAccuracy.png")),
       p_SpC, width = 95, height = 95, units = "mm")


# Step 2: Get to AIMS format, save individual files -----------------------

## Changes needed for AIMS format
# - fix sublocations:
#    - when site is _DUP, sublocation should be SW
#    - when site is a spring, sublocation should be SP
# - siteID should be trimmed to just 5 letters; _1, _2, and _DUP can be determined from sublocation
# - change wetdry from "wet" and "dry" to "1" and "0"
# - rename "siteID" to "siteId"
# - reorder columns

# initialize output data frame
df_wrk <- df_all_raw

# adjust sublocations
subloc <- substr(df_wrk$siteID, start = 6, stop = 50) 
df_wrk$sublocation[subloc == "_2"] <- "LS"
df_wrk$sublocation[subloc == "_1"] <- "HS"
df_wrk$sublocation[subloc == "_DUP"] <- "SW"
df_wrk$sublocation[substr(df_wrk$siteID, 3, 3) == "S"] <- "SP"

table(subloc)
table(df_wrk$sublocation)

# trim siteID to just 5 letters
df_wrk$siteID <- substr(df_wrk$siteID, 1, 5)

# change wetdry to 1 and 0
df_wrk$wetdry[df_wrk$wetdry == "wet"] <- 1
df_wrk$wetdry[df_wrk$wetdry == "dry"] <- 0

table(df_wrk$wetdry)

# reorder columns and rename
df_out <- 
  df_wrk |> 
  rename(siteId = siteID) |> 
  dplyr::select(project, datetime, siteId, rType, sublocation, SN, condUncal,
                tempC, rep, SpC, wetdry, qual_rating, QAQC)

## save in AIMS output format
yrs_to_save <- c(2021, 2022, 2023)
for (yr in yrs_to_save){
  # save CSV for each site and sublocation in this year
  df_out |> 
    subset(year(datetime) == yr) |> 
    group_by(siteId, sublocation) |> 
    group_walk(~ write_csv(.x, 
                           file = file.path(dir_data_final, 
                                            paste0("STIC_GP_", watershed, "_", .y$siteId, 
                                            "_", .y$sublocation, "_", yr, ".csv"))))
}


# Step 3: Summary plots ---------------------------------------------------


# calculate % wet for following scenarios:
# (1) all stics; (2) HS only; (3) HS-excellent; (4) HS-good+excellent; (5) HS-fair+good+excellent
df_all <-
  df_out |> 
  mutate(datetime_round = round_date(datetime, "15 minutes")) |> 
  group_by(datetime_round) |> 
  summarize(n_stic = sum(!is.na(wetdry)),
            prc_wet = sum(wetdry == "1")/n_stic,
            STICs = "All (HS + LS + SP + DUP)")

df_HS <-
  df_out |> 
  subset(sublocation == "HS") |> 
  mutate(datetime_round = round_date(datetime, "15 minutes")) |> 
  group_by(datetime_round) |> 
  summarize(n_stic = sum(!is.na(wetdry)),
            prc_wet = sum(wetdry == "1")/n_stic,
            STICs = "HS: All")

df_HS.e <-
  df_out |> 
  subset(sublocation == "HS" & qual_rating == "excellent") |> 
  mutate(datetime_round = round_date(datetime, "15 minutes")) |> 
  group_by(datetime_round) |> 
  summarize(n_stic = sum(!is.na(wetdry)),
            prc_wet = sum(wetdry == "1")/n_stic,
            STICs = "HS: Excellent")
df_HS.eg <-
  df_out |> 
  subset(sublocation == "HS" & qual_rating %in% c("excellent", "good")) |> 
  mutate(datetime_round = round_date(datetime, "15 minutes")) |> 
  group_by(datetime_round) |> 
  summarize(n_stic = sum(!is.na(wetdry)),
            prc_wet = sum(wetdry == "1")/n_stic,
            STICs = "HS: Excellent+Good")
df_HS.egf <-
  df_out |> 
  subset(sublocation == "HS" & qual_rating %in% c("excellent", "good", "fair")) |> 
  mutate(datetime_round = round_date(datetime, "15 minutes")) |> 
  group_by(datetime_round) |> 
  summarize(n_stic = sum(!is.na(wetdry)),
            prc_wet = sum(wetdry == "1")/n_stic,
            STICs = "HS: Excellent+Good+Fair")

# combine and plot
df_stats <-
  df_all |> 
  bind_rows(df_HS) |> 
  bind_rows(df_HS.e) |> 
  bind_rows(df_HS.eg) |> 
  bind_rows(df_HS.egf)

p_prcwet <- 
  ggplot(df_stats, aes(x = datetime_round, y = prc_wet, color = STICs)) +
  geom_line() +
  scale_y_continuous(name = "% Wet STICs", labels = scales::percent) +
  scale_x_datetime(name = "Datetime [15 min data]", expand = c(0,0)) +
  scale_color_viridis_d() +
  labs(title = paste0(watershed, " % Wet"))

p_nstic <- 
  ggplot(df_stats, aes(x = datetime_round, y = n_stic, color = STICs)) +
  geom_line() +
  scale_y_continuous(name = "# Active STICs") +
  scale_x_datetime(name = "Datetime [15 min data]", expand = c(0,0)) +
  scale_color_viridis_d() +
  labs(title = paste0(watershed, " STIC count"))

# combine and save
p_STICdata <- 
  (p_prcwet + p_nstic) +
  plot_layout(ncol = 1, guides = "collect") &
  theme(legend.position = "bottom")
ggsave(file.path(dir_data_final, "..", paste0(watershed, "_AllSTICs_SummaryPlots.png")),
       p_STICdata, width = 190, height = 120, units = "mm")