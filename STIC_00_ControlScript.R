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

## variables to specify paths, sites, directories for this run.
## needed are:
##  - path_sn_index = path to CSV file linking STIC SNs to sites, used in STIC_01_...
##  - path_calibration_data = path to CSV file with calibration data for each STIC SN, used in STIC_01_...
##  - path_metadata = path to STIC metadata file with field observations
##  - dir_data_raw = directory with raw STIC output data in CSV format (export from HOBOware)
##  - dir_data_classified = directory to save classified output from script STIC_01_...
##  - dir_data_combined = directory to save combined output from script STIC_02_...
##  - dir_data_QAQC = directory to save QAQC output from script STIC_03_...
##  - dir_save_plots = directory to save any visualizations or plots
path_sn_index <- 
path_calibration_data <- 
path_observations <- 
dir_data_raw <- 
dir_data_classified <- 
dir_data_combined <- 
dir_save_plots <- 

## archived variables from past processing runs - must be commented out
# OKA summer 2023 processing by Chris
path_sn_index <- "OKA_STIC_metadata/OKA_STIC_sn_indices/OKA_STIC_sn_index_20220705_20221025.csv"
path_calibration_data <- "OKA_STIC_metadata/OKA_STIC_calibrations/OKA_STIC_calibrations_20220705_20221025.csv"
dir_data_raw <- "OKA_STIC_raw/OKA_STIC_20220705_20221025_raw"
dir_data_classified <- "OKA_STIC_classified"
dir_data_combined <- "OKA_STIC_combined"
dir_data_QAQC <- "OKA_STIC_QAQC"


