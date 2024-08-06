
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cmip6: Straightforward NASA NEX-GDDP-CMIP6 spatial subsets and downloads in R

<!-- badges: start -->

[![GitHub
Release](https://img.shields.io/github/v/release/mt-climate-office/cmip6)](https://github.com/mt-climate-office/cmip6/releases/latest)
[![R-CMD-check](https://github.com/mt-climate-office/cmip6/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mt-climate-office/cmip6/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/mt-climate-office/cmip6/branch/main/graph/badge.svg)](https://app.codecov.io/gh/mt-climate-office/cmip6?branch=main)
<!-- badges: end -->

The goal of cmip6 is to provide a straightforward way to download the
[NASA NEX-GDDP-CMIP6 downscaled climate projection
data](https://www.nccs.nasa.gov/services/data-collections/land-based-products/nex-gddp-cmip6),
either globally or by specifying an area of interest (aoi). Data are
downloaded either from the [NCCS THREDDS Data
Catalog](https://ds.nccs.nasa.gov/thredds/catalog/AMES/NEX/GDDP-CMIP6/catalog.html)
if an aoi is specified (using the NetCDF Subset Service) or the official
[NASA NEX-GDDP-CMIP6 AWS
archive](https://nex-gddp-cmip6.s3.us-west-2.amazonaws.com/index.html)
for global data.

**This package purposefully doesn’t do anything fancy.** It doesn’t load
the downloaded CMIP6 data into R for you. It doesn’t mask the downloaded
data to your aoi. It doesn’t compress the data or otherwise change
whatever is downloaded. It aims to be a lightweight and convenient way
to download the NASA NEX-GDDP-CMIP6 data via R.

## Installation

You can install the latest release of cmip6 from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pkg_install("mt-climate-office/cmip6@*release")
```

Or, install the development version with:

``` r
pak::pkg_install("mt-climate-office/cmip6")
```

## Example

``` r
library(cmip6)

cmip6_dl(
  outdir = tempfile(),
  aoi = sf::st_read(dsn = system.file("shape/nc.shp", package = "sf"),
                    quiet = TRUE),
  models = "GISS-E2-1-G",
  scenarios = c("ssp126", "ssp585"),
  elements = c("tas", "pr"),
  years = 2050:2055
)
```
