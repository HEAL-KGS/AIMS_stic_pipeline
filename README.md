This is a pipeline used by the [AIMS project](https://osf.io/7gb5p/) for processing stream temperature, intermittency, and conductivity (STIC) logger data. It makes heavy use of the [STICr package](https://github.com/HEAL-KGS/STICr) and takes the data through a processing pipeline to transform it from raw HOBO output data to QAQCed, classified, and calibrated STIC data.

The steps in the pipeline are used as follows: 

 - `STIC_00_ControlScript.R` should be updated first with the relevant paths and site info, as this will be sourced in all subsequent scripts.
 - `STIC_01_Tidy+Calibrate+ClassifyData.R`:
    - Load data and tidy data (convert from HOBO file format to tidy data frame)
    - Identify site name based on serial number and download period
    - Apply calibrations to get SpC
    - Classify data and determine some QAQC flags (outside calibration standard range)
    - Save classified output to a directory
 - `STIC_02_QAQCdata.R`:
    - Conduct additional automated QAQC steps
    - Requires user input for qualitative rating criteria
    - Save QAQCed output and plots
 - `STIC_03_CombineData+PlotTimeseries.R`:
    - Combine files from different download periods at the same site to make a single file for each site with the whole period of record
    - Plot combined timeseries
 - `STIC_04_Validate+Finalize.R`:
    - Load all STIC data from all sites
    - Vaildate via comparison with field observations of wetdry status and SpC
    - Save out in required AIMS format (one file per site and year)

There are also several 'one-time-use' scripts that accomplished certain necessary tasks:

 - `XX_UpdateQAQCflags.R`: After some of the data was processed, we changed the flags used for QAQC steps, so this updated from the old flags to the new flags.
 - `XX_UpdateWetdryThres.R`: Based on accuracy assessment, we changed the threshold for wetdry classification after some of the processing steps had been completed. This updates the old classification to the new classification.



 