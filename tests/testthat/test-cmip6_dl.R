test_that("AWS downloads work", {
  expect_s3_class(
    cmip6_dl(
      outdir = tempfile(),
      models = "GISS-E2-1-G",
      scenarios = "ssp585",
      elements = "tas",
      years = 2050
    ),
    "data.frame"
  )
})

test_that("TDS downloads work", {
  nc <- sf::st_read(
    system.file("shape/nc.shp", package = "sf"),
    quiet = TRUE
    )
  expect_s3_class(
    cmip6_dl(
      outdir = tempfile(),
      aoi = nc,
      models = "GISS-E2-1-G",
      scenarios = "ssp585",
      elements = "tas",
      years = 2050
    ),
    "data.frame"
  )
})

test_that("TDS base path exists", {
  expect_false(
    "https://ds.nccs.nasa.gov/thredds/" |>
      httr2::request() |>
      httr2::req_method("HEAD") |>
      httr2::req_perform() |>
      httr2::resp_is_error()
  )
})

test_that("TDS data exists where expected", {
  test_data <-
    cmip6_ls() |>
    dplyr::sample_n(1)

  expect_false(
    test_data$path |>
      sub(
        pattern = "NEX-GDDP-CMIP6",
        replacement = "NEX/GDDP-CMIP6",
        x = _
      ) |>
      file.path(
        "https://ds.nccs.nasa.gov/thredds/ncss/grid/AMES",
        `...` = _
      ) |>
      httr2::request() |>
      httr2::req_url_query(
        var = test_data$element,
        north = 51,
        west = 20,
        east = 21,
        south = 50,
        disableProjSubset = "on",
        horizStride = 1,
        time_start = paste0(test_data$year, "-01-01"),
        time_end = paste0(as.integer(test_data$year) + 1, "-01-01"),
        timeStride = 1,
        addLatLon = TRUE
      ) |>
      httr2::req_method("HEAD") |>
      httr2::req_perform() |>
      httr2::resp_is_error()
  )
})

test_that("AWS base path exists", {
  expect_false(
    "https://nex-gddp-cmip6.s3-us-west-2.amazonaws.com" |>
      httr2::request() |>
      httr2::req_method("HEAD") |>
      httr2::req_perform() |>
      httr2::resp_is_error()
  )
})

test_that("AWS data exists where expected", {
  expect_false(
    cmip6_ls()$path |>
      sample(size = 1) |>
      file.path("https://nex-gddp-cmip6.s3-us-west-2.amazonaws.com",
                `...` = _) |>
      httr2::request() |>
      httr2::req_method("HEAD") |>
      httr2::req_perform() |>
      httr2::resp_is_error()
  )
})

test_that("mutually exclusive plan throws error", {
  expect_error(
    cmip6_dl(
      outdir = tempfile(),
      models = "GISS-E2-1-G",
      scenarios = c("ssp126", "ssp585"),
      elements = c("tas", "pr"),
      years = 1985
    )
  )
})

