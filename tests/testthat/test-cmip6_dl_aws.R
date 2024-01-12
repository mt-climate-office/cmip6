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
