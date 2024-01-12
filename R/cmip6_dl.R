#' Download NASA NEX-GDDP-CMIP6 Data
#'
#' Data are downloaded either from the NCCS THREDDS Data Catalog (using the
#' NetCDF Subset Service) or the official NASA NEX-GDDP-CMIP6 AWS archive. This
#' function chooses which service to download from based on whether the user
#' specifies an area of interest (`aoi`).
#'
#' Specify an `aoi` as an [`sf`] object to crop data to a
#' specific bounding box. Downloaded data are *not* masked to the `sf` object,
#' merely constrained to its bounding box.
#'
#' @param outdir The directory to which to write the downloaded data. Defaults
#' to the current working directory.
#' @param aoi Optional. An [`sf`] object specifying an area of interest.
#' If omitted, data for the entire globe are downloaded.
#' @param models Optional. A character vector of models to download. If
#' omitted, all models are downloaded.
#' @param scenarios Optional. A character vector of scenarios (shared
#' socioeconomic pathways) to download. If omitted, all scenarios are
#' downloaded.
#' @param elements Optional. A character vector of elements (meteorological
#' variables) to download. If omitted, all elements are downloaded.
#' @param years Optional. An integer vector of years to download. If omitted,
#' all years are downloaded. Data area available from 1950--2100.
#' @param latest Whether to remove legacy versions of the data where
#' new ones exist. Defaults to TRUE.
#' @param workers Parallelization is supported by default with 10 workers.
#' Specify an integer value of more or fewer workers if desired. Note that
#' specifying too many workers may cause download requests to be rejected
#' by the NASA NEX-GDDP-CMIP6 host servers.
#' @param force Whether to re-download data that already exists on disk.
#' Defaults to `FALSE`.
#'
#' @return A [`tibble::tbl_df`] listing the downloaded data.
#' @export
#'
#' @examples
#' cmip6_dl(
#'   outdir = tempfile(),
#'   models = "GISS-E2-1-G",
#'   scenarios = "ssp585",
#'   elements = "tas",
#'   years = 2050
#' )
#'
#' nc <- sf::st_read(system.file("shape/nc.shp", package = "sf"))
#' cmip6_dl(
#'   outdir = tempfile(),
#'   aoi = nc,
#'   models = "GISS-E2-1-G",
#'   scenarios = "ssp585",
#'   elements = "tas",
#'   years = 2050
#' )
cmip6_dl <-
  function(outdir = getwd(),
           aoi = NULL,
           models = NULL,
           scenarios = NULL,
           elements = NULL,
           years = NULL,
           latest = TRUE,
           workers = 10,
           force = FALSE) {
    # Create the output directory, recursively if necessary
    dir.create(outdir,
      recursive = TRUE,
      showWarnings = FALSE
    )

    plan <-
      cmip6_ls(latest = latest) |>
      dplyr::filter(
        if (!is.null(models)) (model %in% models) else (1 == 1),
        if (!is.null(scenarios)) (scenario %in% scenarios) else (1 == 1),
        if (!is.null(elements)) (element %in% elements) else (1 == 1),
        if (!is.null(years)) (year %in% years) else (1 == 1)
      )

    if(nrow(plan) == 0)
      stop("No CMIP6 data to be downloaded: filters are mutually exclusive!")

    if (is.null(aoi)) {
      return(
        cmip6_dl_aws(
          plan = plan,
          outdir = outdir,
          workers = workers,
          force = force
        )
      )
    }

    return(
      cmip6_dl_tds(
        aoi = aoi,
        plan = plan,
        outdir = outdir,
        workers = workers,
        force = force
      )
    )
  }
