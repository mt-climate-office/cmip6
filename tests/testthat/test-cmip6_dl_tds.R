test_data <-
  cmip6_ls() |>
  dplyr::slice_sample(n = 1)

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
        north = 50,
        west = 20,
        east = 30,
        south = 45,
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
