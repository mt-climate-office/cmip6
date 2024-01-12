
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cmip6: Straightforward NASA NEX-GDDP-CMIP6 spatial subsets and downloads in R

<!-- badges: start -->

[![R-CMD-check](https://github.com/mt-climate-office/cmip6/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mt-climate-office/cmip6/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/mt-climate-office/cmip6/branch/main/graph/badge.svg)](https://app.codecov.io/gh/mt-climate-office/cmip6?branch=main)
<!-- badges: end -->

The goal of cmip6 is to provide a straightforward way to download the
NASA NEX-GDDP-CMIP6 downscaled climate projection data, either globally
or by specifying an area of interest (aoi). Data are downloaded either
from the NCCS THREDDS Data Catalog if an aoi is specified (using the
NetCDF Subset Service) or the official NASA NEX-GDDP-CMIP6 AWS archive
for global data.

## Installation

You can install the development version of cmip6 from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pkg_install("mt-climate-office/cmip6")
```

## Example

``` r
library(cmip6)

nc <- 
  sf::st_read(
    dsn = system.file("shape/nc.shp", package = "sf"),
    quiet = TRUE
  )

outdir <- tempfile()

cmip6_dl(
  outdir = outdir,
  aoi = nc,
  models = "GISS-E2-1-G",
  scenarios = c("ssp126", "ssp585"),
  elements = c("tas", "pr"),
  years = 2050:2055
)
```
