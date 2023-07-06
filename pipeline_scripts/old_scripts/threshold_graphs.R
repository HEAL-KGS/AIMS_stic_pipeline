# threshold_graphs.R
# Script to make graphs for looking at thresholds for each site and download period
# Choosing three files randomly from each site and download (9 total YMR and 12 total for KNZ)

library(tidyverse)
library(STICr)

# Starting with YMR: 

# Download 1 YMR: ENM05, EN305, EN202

# ENM05:
ENM05_d1 <- read_csv("YMR_STIC_classified/20210716-20220209_ENM05_STIC_00_LS.csv", col_types = cols(datetime = col_character())) %>% 
  mutate(datetime = lubridate::ymd_hms(datetime))

ggplot(ENM05_d1, aes(x = datetime, y = SpC, color = wetdry)) + 
  geom_point() + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  ggtitle("ENM05_d1; SpC = 200") + 
  theme(plot.title = element_text(hjust = 0.5))

ggsave("1.png")

# EN305:
EN305_d1 <- read_csv("YMR_STIC_classified/20210716-20220209_EN305_STIC_00_LS.csv", col_types = cols(datetime = col_character())) %>% 
  mutate(datetime = lubridate::ymd_hms(datetime))

ggplot(EN305_d1, aes(x = datetime, y = SpC, color = wetdry)) + 
  geom_point() + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  ggtitle("EN305_d1; SpC = 200") + 
  theme(plot.title = element_text(hjust = 0.5))

ggsave("2.png")

# EN202:
EN202_d1 <- read_csv("YMR_STIC_classified/20210716-20220209_EN202_STIC_00_LS.csv", col_types = cols(datetime = col_character())) %>% 
  mutate(datetime = lubridate::ymd_hms(datetime))

ggplot(EN202_d1, aes(x = datetime, y = SpC, color = wetdry)) + 
  geom_point() + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  ggtitle("EN202_d1; SpC = 200") + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave("3.png")
# Download 2 YMR: EN203, ENM01, EN302

# EN203:
EN203_d2 <- read_csv("YMR_STIC_classified/20220209-20220803_EN203_STIC_00_LS.csv", col_types = cols(datetime = col_character())) %>% 
  mutate(datetime = lubridate::ymd_hms(datetime))

ggplot(EN203_d2, aes(x = datetime, y = SpC, color = wetdry)) + 
  geom_point() + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  ggtitle("EN203_d2; SpC = 200") + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave("4.png")
# ENM01:
ENM01_d2 <- read_csv("YMR_STIC_classified/20220209-20220803_ENM01_STIC_00_HS.csv", col_types = cols(datetime = col_character())) %>% 
  mutate(datetime = lubridate::ymd_hms(datetime))

ggplot(ENM01_d2, aes(x = datetime, y = SpC, color = wetdry)) + 
  geom_point() + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  ggtitle("ENM01_d2; SpC = 200") + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave("5.png")
# EN302:
EN302_d2 <- read_csv("YMR_STIC_classified/20220209-20221208_EN302_STIC_00_LS.csv", col_types = cols(datetime = col_character())) %>% 
  mutate(datetime = lubridate::ymd_hms(datetime))

ggplot(EN302_d2, aes(x = datetime, y = SpC, color = wetdry)) + 
  geom_point() + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  ggtitle("EN302_d2; SpC = 200") + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave("6.png")
# Download 3 YMR: EN206, ENM01, EN101

# EN206:
EN206_d3 <- read_csv("YMR_STIC_classified/20220803-20230315_EN206_STIC_00_LS.csv", col_types = cols(datetime = col_character())) %>% 
  mutate(datetime = lubridate::ymd_hms(datetime))

ggplot(EN206_d3, aes(x = datetime, y = SpC, color = wetdry)) + 
  geom_point() + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  ggtitle("EN206_d3; SpC = 200") + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave("7.png")
# ENM01:
ENM01_d3 <- read_csv("YMR_STIC_classified/20220803-20230315_ENM01_STIC_00_HS.csv", col_types = cols(datetime = col_character())) %>% 
  mutate(datetime = lubridate::ymd_hms(datetime))

ggplot(ENM01_d3, aes(x = datetime, y = SpC, color = wetdry)) + 
  geom_point() + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  ggtitle("ENM01_d3; SpC = 200") + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave("8.png")
# EN101:
EN101_d3 <- read_csv("YMR_STIC_classified/20220803-20230315_EN101_STIC_00_HS.csv", col_types = cols(datetime = col_character())) %>% 
  mutate(datetime = lubridate::ymd_hms(datetime))

ggplot(EN101_d3, aes(x = datetime, y = SpC, color = wetdry)) + 
  geom_point() + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  ggtitle("EN101_d3; SpC = 200") + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave("9.png")

# Now doing KNZ: 

# Download 1 KNZ: SFT01_1_d1, d1_04M06_1, d1_20M05_1

# SFT01_1_d1:
SFT01_1_d1 <- read_csv("KNZ_STIC_classified/20210520-20210902_SFT01_1_STIC_00_HS.csv", col_types = cols(datetime = col_character())) %>% 
  mutate(datetime = lubridate::ymd_hms(datetime))

ggplot(SFT01_1_d1, aes(x = datetime, y = SpC, color = wetdry)) + 
  geom_point() + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  ggtitle("SFT01_1_d1; SpC = 200") + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave("10.png")
# d1_04M06_1:
d1_04M06_1 <- read_csv("KNZ_STIC_classified/20210520-20210915_04M06_1_STIC_00_HS.csv", col_types = cols(datetime = col_character())) %>% 
  mutate(datetime = lubridate::ymd_hms(datetime))

ggplot(d1_04M06_1, aes(x = datetime, y = SpC, color = wetdry)) + 
  geom_point() + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  ggtitle("d1_04M06_1; SpC = 200") + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave("11.png")
# d1_20M05_1:
d1_20M05_1 <- read_csv("KNZ_STIC_classified/20210520-20210917_20M05_1_STIC_00_HS.csv", col_types = cols(datetime = col_character())) %>% 
  mutate(datetime = lubridate::ymd_hms(datetime))

ggplot(d1_20M05_1, aes(x = datetime, y = SpC, color = wetdry)) + 
  geom_point() + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  ggtitle("d1_20M05_1; SpC = 200") + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave("12.png")
# Download 2 KNZ: 

# d2_04M11_1:
d2_04M11_1 <- read_csv("KNZ_STIC_classified/20210917-20220112_04M11_1_STIC_00_HS.csv", col_types = cols(datetime = col_character())) %>% 
  mutate(datetime = lubridate::ymd_hms(datetime))

ggplot(d2_04M11_1, aes(x = datetime, y = SpC, color = wetdry)) + 
  geom_point() + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  ggtitle("d2_04M11_1; SpC = 200") + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave("13.png")
# d2_02M06_1:
d2_02M06_1 <- read_csv("KNZ_STIC_classified/20210917-20220112_02M06_1_STIC_00_HS.csv", col_types = cols(datetime = col_character())) %>% 
  mutate(datetime = lubridate::ymd_hms(datetime))

ggplot(d2_02M06_1, aes(x = datetime, y = SpC, color = wetdry)) + 
  geom_point() + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  ggtitle("d2_02M06_1; SpC = 200") + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave("14.png")
# d2_SFM04_1:
d2_SFM04_1 <- read_csv("KNZ_STIC_classified/20210902-20220112_SFM04_1_STIC_00_HS.csv", col_types = cols(datetime = col_character())) %>% 
  mutate(datetime = lubridate::ymd_hms(datetime))

ggplot(d2_SFM04_1, aes(x = datetime, y = SpC, color = wetdry)) + 
  geom_point() + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  ggtitle("d2_SFM04_1; SpC = 200") + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave("15.png")
# Download 3 KNZ: 

# d3_04M02_2:
d3_04M02_2 <- read_csv("KNZ_STIC_classified/20220114-20220425_04M02_2_STIC_00_LS.csv", col_types = cols(datetime = col_character())) %>% 
  mutate(datetime = lubridate::ymd_hms(datetime))

ggplot(d3_04M02_2, aes(x = datetime, y = condUncal, color = wetdry)) + 
  geom_point() + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  ggtitle("d3_04M02_2; condUncal = 1000") + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave("16.png")
# d3_02M11_2:
d3_02M11_2 <- read_csv("KNZ_STIC_classified/20220114-20220720_02M11_2_STIC_00_LS.csv", col_types = cols(datetime = col_character())) %>% 
  mutate(datetime = lubridate::ymd_hms(datetime))

ggplot(d3_02M11_2, aes(x = datetime, y = condUncal, color = wetdry)) + 
  geom_point() + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  ggtitle("d3_02M11_2; condUncal = 1000") + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave("17.png")
# d3_04M01_2:
d3_04M01_2 <- read_csv("KNZ_STIC_classified/20220114-20220720_04M01_2_STIC_00_LS.csv", col_types = cols(datetime = col_character())) %>% 
  mutate(datetime = lubridate::ymd_hms(datetime))

ggplot(d3_04M01_2, aes(x = datetime, y = condUncal, color = wetdry)) + 
  geom_point() + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  ggtitle("d3_04M01_2; condUncal = 1000") + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave("18.png")
# Download 4 KNZ: d3_04M03_1, d3_04M11_1, d3_02M11_1

# d4_04M03_1
d4_04M03_1 <- read_csv("KNZ_STIC_classified/20220721-20230116_04M03_1_STIC_00_HS.csv", col_types = cols(datetime = col_character())) %>% 
  mutate(datetime = lubridate::ymd_hms(datetime))

ggplot(d4_04M03_1, aes(x = datetime, y = condUncal, color = wetdry)) + 
  geom_point() + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  ggtitle("d4_04M03_1; condUncal = 1000") + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave("19.png")
# d4_04M11_1
d4_04M11_1 <- read_csv("KNZ_STIC_classified/20220721-20230116_04M11_1_STIC_00_HS.csv", col_types = cols(datetime = col_character())) %>% 
  mutate(datetime = lubridate::ymd_hms(datetime))

ggplot(d4_04M11_1, aes(x = datetime, y = SpC, color = wetdry)) + 
  geom_point() + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  ggtitle("d4_04M11_1; SpC = 200") + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave("20.png")
# d4_02M11_1
d4_02M11_1 <- read_csv("KNZ_STIC_classified/20220527-20230116_02M11_1_STIC_00_HS.csv", col_types = cols(datetime = col_character())) %>% 
  mutate(datetime = lubridate::ymd_hms(datetime))

ggplot(d4_02M11_1, aes(x = datetime, y = condUncal, color = wetdry)) + 
  geom_point() + 
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  ggtitle("d4_02M11_1; condUncal = 1000") + 
  theme(plot.title = element_text(hjust = 0.5))
ggsave("21.png")