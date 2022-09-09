04M09_2 STIC Summary
================
Christopher Wheeler
2022-09-08

## Bring in processed STIC data frame

    ## Warning: package 'tidyverse' was built under R version 4.1.3

    ## Warning: package 'tibble' was built under R version 4.1.3

    ## Warning: package 'tidyr' was built under R version 4.1.3

    ## Warning: package 'dplyr' was built under R version 4.1.3

    ## Warning: 1 parsing failure.
    ##   row       col           expected actual                       file
    ## 17950 field_SpC 1/0/T/F/TRUE/FALSE    572 'STIC_KNZ_04M09_00_LS.csv'

    ## # A tibble: 6 x 16
    ##   project datetime            siteID  rType   rep subloca~1     SN condU~2 tempC
    ##   <chr>   <dttm>              <chr>   <chr> <dbl> <chr>      <dbl>   <dbl> <dbl>
    ## 1 AIMS    2022-01-14 17:00:00 04M09_2 STIC      0 LS        2.10e7   2927.  6.98
    ## 2 AIMS    2022-01-14 17:15:00 04M09_2 STIC      0 LS        2.10e7   2927.  6.57
    ## 3 AIMS    2022-01-14 17:30:00 04M09_2 STIC      0 LS        2.10e7   2927.  5.35
    ## 4 AIMS    2022-01-14 17:45:00 04M09_2 STIC      0 LS        2.10e7   3099.  4.10
    ## 5 AIMS    2022-01-14 18:00:00 04M09_2 STIC      0 LS        2.10e7   3615.  3.26
    ## 6 AIMS    2022-01-14 18:15:00 04M09_2 STIC      0 LS        2.10e7   3615.  2.41
    ## # ... with 7 more variables: SpC <dbl>, wetdry <chr>, watershed <chr>,
    ## #   QAQC <chr>, lat <dbl>, long <dbl>, field_SpC <dbl>, and abbreviated
    ## #   variable names 1: sublocation, 2: condUncal

## Time series of SpC colored by wet/dry designation (red dot represents field SpC measurement)

    ## Warning: Removed 17949 rows containing missing values (geom_point).

![](qaqc_markdown_doc_files/figure-gfm/Spc%20time%20series-1.png)<!-- -->

## Time series of Temperature (C) recorded by STIC

![](qaqc_markdown_doc_files/figure-gfm/temp%20time%20series-1.png)<!-- -->

## Map of STIC location

    ## Warning: package 'lattice' was built under R version 4.1.3

    ## Reading layer `GIS210' from data source 
    ##   `C:\Users\cwhee\Dropbox\PC\Desktop\R_Directory\AIMS_stic_pipeline\GIS210\GIS210.shp' 
    ##   using driver `ESRI Shapefile'
    ## Simple feature collection with 96 features and 4 fields
    ## Geometry type: LINESTRING
    ## Dimension:     XY
    ## Bounding box:  xmin: 706268.8 ymin: 4326846 xmax: 712897.1 ymax: 4334446
    ## Projected CRS: NAD83 / UTM zone 14N

![](qaqc_markdown_doc_files/figure-gfm/STIC%20location%20map-1.png)<!-- -->

## Scatterplot of STIC-measured SpC values versus YSI field measuremnts

still need to make
