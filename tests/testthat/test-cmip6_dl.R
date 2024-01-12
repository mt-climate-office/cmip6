test_that("AWS downloads work", {
  cmip6_dl(
    outdir = tempfile(),
    models = "GISS-E2-1-G",
    scenarios = "ssp585",
    elements = "tas",
    years = 2050
  )
})

test_that("TDS downloads work", {
  nc <- sf::st_read(system.file("shape/nc.shp", package = "sf"))
  cmip6_dl(
    outdir = tempfile(),
    aoi = nc,
    models = "GISS-E2-1-G",
    scenarios = "ssp585",
    elements = "tas",
    years = 2050
  )
})
