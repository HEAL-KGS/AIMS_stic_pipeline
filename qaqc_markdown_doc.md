04M09_2 STIC Summary
================
Christopher Wheeler
2022-09-08

## Bring in processed STIC data frame

``` r
library(tidyverse)
```

    ## Warning: package 'tidyverse' was built under R version 4.1.3

    ## -- Attaching packages --------------------------------------- tidyverse 1.3.1 --

    ## v ggplot2 3.3.5     v purrr   0.3.4
    ## v tibble  3.1.8     v dplyr   1.0.9
    ## v tidyr   1.2.0     v stringr 1.4.0
    ## v readr   1.4.0     v forcats 0.5.1

    ## Warning: package 'tibble' was built under R version 4.1.3

    ## Warning: package 'tidyr' was built under R version 4.1.3

    ## Warning: package 'dplyr' was built under R version 4.1.3

    ## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
STIC_KNZ_04M09_00_LS <- read_csv("STIC_KNZ_04M09_00_LS.csv")
```

    ## 
    ## -- Column specification --------------------------------------------------------
    ## cols(
    ##   project = col_character(),
    ##   datetime = col_datetime(format = ""),
    ##   siteID = col_character(),
    ##   rType = col_character(),
    ##   rep = col_double(),
    ##   sublocation = col_character(),
    ##   SN = col_double(),
    ##   condUncal = col_double(),
    ##   tempC = col_double(),
    ##   SpC = col_double(),
    ##   wetdry = col_character(),
    ##   watershed = col_character(),
    ##   QAQC = col_character(),
    ##   lat = col_double(),
    ##   long = col_double(),
    ##   field_SpC = col_logical()
    ## )

    ## Warning: 1 parsing failure.
    ##   row       col           expected actual                       file
    ## 17950 field_SpC 1/0/T/F/TRUE/FALSE    572 'STIC_KNZ_04M09_00_LS.csv'

``` r
STIC_KNZ_04M09_00_LS$field_SpC <- as.numeric(STIC_KNZ_04M09_00_LS$field_SpC)

STIC_KNZ_04M09_00_LS[17950, 16] <- 572

head(STIC_KNZ_04M09_00_LS)
```

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

``` r
ggplot(STIC_KNZ_04M09_00_LS, aes(x = datetime, y = SpC, color = wetdry, group = 1)) + 
  geom_path(size = 0.7) + 
  geom_point(aes(x = datetime, y = field_SpC), size = 3, color = "red") +
   theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14))
```

    ## Warning: Removed 17949 rows containing missing values (geom_point).

![](qaqc_markdown_doc_files/figure-gfm/Spc%20time%20series-1.png)<!-- -->

## Time series of Temperature (C) recorded by STIC

``` r
ggplot(STIC_KNZ_04M09_00_LS, aes(x = datetime, y = tempC)) + 
  geom_path() + 
  geom_smooth(color = "steelblue", se = FALSE) +
   theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14))
```

    ## `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'

![](qaqc_markdown_doc_files/figure-gfm/temp%20time%20series-1.png)<!-- -->

## Map of STIC location

``` r
library(Rcpp)
library(sp)
library(raster)
```

    ## 
    ## Attaching package: 'raster'

    ## The following object is masked from 'package:dplyr':
    ## 
    ##     select

    ## The following object is masked from 'package:tidyr':
    ## 
    ##     extract

``` r
library(rgdal)
```

    ## rgdal: version: 1.5-23, (SVN revision 1121)
    ## Geospatial Data Abstraction Library extensions to R successfully loaded
    ## Loaded GDAL runtime: GDAL 3.2.1, released 2020/12/29
    ## Path to GDAL shared files: C:/Users/cwhee/Documents/R/win-library/4.1/rgdal/gdal
    ## GDAL binary built with GEOS: TRUE 
    ## Loaded PROJ runtime: Rel. 7.2.1, January 1st, 2021, [PJ_VERSION: 721]
    ## Path to PROJ shared files: C:/Users/cwhee/Documents/R/win-library/4.1/rgdal/proj
    ## PROJ CDN enabled: FALSE
    ## Linking to sp version:1.4-5
    ## To mute warnings of possible GDAL/OSR exportToProj4() degradation,
    ## use options("rgdal_show_exportToProj4_warnings"="none") before loading rgdal.
    ## Overwritten PROJ_LIB was C:/Users/cwhee/Documents/R/win-library/4.1/rgdal/proj

``` r
library(rasterVis)
```

    ## Loading required package: terra

    ## terra version 1.3.4

    ## 
    ## Attaching package: 'terra'

    ## The following object is masked from 'package:rgdal':
    ## 
    ##     project

    ## The following object is masked from 'package:dplyr':
    ## 
    ##     src

    ## Loading required package: lattice

    ## Warning: package 'lattice' was built under R version 4.1.3

    ## Loading required package: latticeExtra

    ## 
    ## Attaching package: 'latticeExtra'

    ## The following object is masked from 'package:ggplot2':
    ## 
    ##     layer

``` r
library(sf)
```

    ## Linking to GEOS 3.9.0, GDAL 3.2.1, PROJ 7.2.1

``` r
# Bring in stream line shape files
konza_streams <- st_read("GIS210/GIS210.shp")
```

    ## Reading layer `GIS210' from data source 
    ##   `C:\Users\cwhee\Dropbox\PC\Desktop\R_Directory\AIMS_stic_pipeline\GIS210\GIS210.shp' 
    ##   using driver `ESRI Shapefile'
    ## Simple feature collection with 96 features and 4 fields
    ## Geometry type: LINESTRING
    ## Dimension:     XY
    ## Bounding box:  xmin: 706268.8 ymin: 4326846 xmax: 712897.1 ymax: 4334446
    ## Projected CRS: NAD83 / UTM zone 14N

``` r
stic_location <- st_as_sf(STIC_KNZ_04M09_00_LS,
                                coords = c("long", "lat"), 
                                crs = 4326)

ggplot() + 
  geom_sf(data = konza_streams) + 
  geom_sf(data = stic_location, size = 3, color = "red") +
  theme_bw() + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", size = 1)) + 
  theme(axis.text = element_text(size = 9),
        axis.title = element_text(size = 12)) +
  xlab("Longitude") + 
  ylab("Latitude") + 
  coord_sf(xlim = c(708000.9  , 710500.3 ), ylim = c(4327200.8  , 4330000.0 ), expand = FALSE)
```

![](qaqc_markdown_doc_files/figure-gfm/STIC%20location%20map-1.png)<!-- -->

## Scatterplot of STIC-measured SpC values versus YSI field measuremnts

still need to make
