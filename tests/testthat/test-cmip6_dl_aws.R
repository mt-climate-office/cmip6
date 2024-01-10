test_that("AWS downloads work", {
  outdir <- tempfile()

  cmip6_dl(outdir = outdir,
           models = "GISS-E2-1-G",
           years = 1985)
})
