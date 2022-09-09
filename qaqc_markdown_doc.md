04M09_2 STIC Summary
================
Christopher Wheeler
2022-09-08

## Bring in processed STIC data frame

``` r
library(tidyverse)
```

    ## Warning: package 'tidyverse' was built under R version 4.1.3

    ## Warning: package 'tibble' was built under R version 4.1.3

    ## Warning: package 'tidyr' was built under R version 4.1.3

    ## Warning: package 'dplyr' was built under R version 4.1.3

``` r
STIC_KNZ_04M09_00_LS <- read_csv("STIC_KNZ_04M09_00_LS.csv")
```

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

![](qaqc_markdown_doc_files/figure-gfm/temp%20time%20series-1.png)<!-- -->

## Map of STIC location

``` r
library(Rcpp)
library(sp)
library(raster)
library(rgdal)
library(rasterVis)
```

    ## Warning: package 'lattice' was built under R version 4.1.3

``` r
library(sf)

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
