## STIC_00_ControlScript.R
#' This script contains paths and variables used across each of the pipeline scripts.
#' By having them in one place, it will make it reproducible for future analyses.
#' This script is sourced in each of the pipeline scripts (STIC_01_, STIC_02_, ...)

## Load packages (do not change for each run)
# if needed: install STICr
#library(devtools)
#devtools::install_github("HEAL-KGS/STICr")
library(STICr)
library(tidyverse)
library(gridExtra) # for tableGrob
library(patchwork)

## Specify root path - this will likely vary as a function of what computer you are 
## working on, but should not be changed for specific sites.
## this should point to the AIMS working data folder for Approach 1 STICs/Great_Plains
## which is here: https://drive.google.com/drive/folders/1aMPuTPHhOdN2YyCC54Y0gz34fGjXNmQf
path_root <- "G:/.shortcut-targets-by-id/1KSx3E1INg4hQNlHWYnygPi41k_ku66fz/Track 2 AIMS/Data [working files]/Core datasets (as defined by implementation plan)/Approach 1_sensors and STICs/STICs/Great_Plains"

## variables to specify paths, sites, directories for this run.
## all paths should be relative to path_root
## variables needed are:
##  - path_sn_index = path to CSV file linking STIC SNs to sites, used in STIC_01_...
##  - path_observations = path to STIC metadata file with field observations
##  - dir_data_raw = directory with raw STIC output data in CSV format (export from HOBOware)
##  - dir_data_classified = directory to save classified output from script STIC_01_...
##  - dir_data_combined = directory to save combined output from script STIC_02_...
##  - dir_data_QAQC = directory to save QAQC output from script STIC_03_...
##  - dir_save_plots = directory to save any visualizations or plots from script STIC_04_...
# KNZ OCTOBER 2023
path_sn_index <- file.path(path_root, "KNZ_STIC_sn_indices", "KNZ+SHN_STIC_sn_index_20231016-collection.csv")
path_observations <- file.path(path_root, "KNZ_STIC_metadata", "KNZ_STIC_QAQC_metadata.csv")
dir_data_raw <- file.path(path_root, "KNZ_STIC_raw" , "KNZ_STIC_202301_202310_raw")
dir_data_classified <- file.path(path_root, "KNZ_STIC_classified")
dir_data_qaqc <- file.path(path_root, "KNZ_STIC_qaqc")
dir_save_plots <- file.path(path_root, "KNZ_STIC_plots")

## archived variables from past processing runs - must be commented out
# OKA summer 2023 processing by Chris
#path_sn_index <- "OKA_STIC_metadata/OKA_STIC_sn_indices/OKA_STIC_sn_index_20220705_20221025.csv"
#path_calibration_data <- "OKA_STIC_metadata/OKA_STIC_calibrations/OKA_STIC_calibrations_20220705_20221025.csv"
#dir_data_raw <- "OKA_STIC_raw/OKA_STIC_20220705_20221025_raw"
#dir_data_classified <- "OKA_STIC_classified"
#dir_data_combined <- "OKA_STIC_combined"
#dir_data_QAQC <- "OKA_STIC_QAQC"