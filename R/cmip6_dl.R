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
#' by the NASA NEX-GDDP-CMIP6 host servers. We recommend 10 or fewer workers.
#' @param force Whether to re-download data that already exists on disk.
#' Defaults to `FALSE`.
#'
#' @return A [`tibble::tbl_df`] listing the downloaded data and their source
#' urls.
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
#' aoi <-
#'   sf::st_read(
#'     system.file("shape/nc.shp", package = "sf"),
#'     quiet = TRUE
#'   )
#' cmip6_dl(
#'   outdir = tempfile(),
#'   aoi = aoi,
#'   models = "GISS-E2-1-G",
#'   scenarios = c("ssp126", "ssp585"),
#'   elements = c("tas", "pr"),
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

    if(!is.null(aoi)){
      # This is a bit convoluted, but handles sf, sfc, and bbox objects
      if(inherits(aoi, "bbox"))
        aoi <- sf::st_as_sfc(aoi)

      if(inherits(aoi, "sfc"))
        aoi <- sf::st_sf(aoi)

      aoi <-
        aoi |>
        sf::st_transform(4326) |>
        st_rotate() |>
        sf::st_bbox() |>
        as.list()

      message(
        "FYI: Your AOI bounding box in CMIP6 coordinates is\n",
        "  West: ", round(aoi$xmin, 3), "\u00B0\n",
        "  East: ", round(aoi$xmax, 3), "\u00B0\n",
        "  South: ", round(aoi$ymin, 3), "\u00B0\n",
        "  North: ", round(aoi$ymax, 3), "\u00B0\n"
      )
    }

    plan <-
      cmip6_ls(latest = latest) |>
      dplyr::filter(
        if (!is.null(models)) (model %in% models) else (1 == 1),
        if (!is.null(scenarios)) (scenario %in% scenarios) else (1 == 1),
        if (!is.null(elements)) (element %in% elements) else (1 == 1),
        if (!is.null(years)) (year %in% years) else (1 == 1)
      ) |>
      dplyr::mutate(
        file =
          file.path(
            outdir,
            dataset
          )
      ) |>
      {\(.) if(nrow(.) == 0)
        stop("No CMIP6 data to be downloaded: filters are mutually exclusive!",
             call. = FALSE)
        else . }() |>
      dplyr::rowwise() |>
      {\(.) if(is.null(aoi))
        dplyr::mutate(
          .,
          request =
            list(
              file.path(
                "https://nex-gddp-cmip6.s3-us-west-2.amazonaws.com",
                path
              ) |>
                httr2::request()
            )
        )
        else
          dplyr::mutate(
            .,
            request =
              list(
                file.path(
                  "https://ds.nccs.nasa.gov/thredds/ncss/grid/AMES",
                  sub(
                    pattern = "NEX-GDDP-CMIP6",
                    replacement = "NEX/GDDP-CMIP6",
                    x = path
                  )
                ) |>
                  httr2::request() |>
                  httr2::req_url_query(
                    var = element,
                    north = aoi$ymax,
                    west = aoi$xmin,
                    east = aoi$xmax,
                    south = aoi$ymin,
                    disableProjSubset = "on",
                    horizStride = 1,
                    time_start = paste0(year, "-01-01"),
                    time_end = paste0(as.integer(year) + 1, "-01-01"),
                    timeStride = 1,
                    addLatLon = TRUE
                  )
              )
          )
      }() |>
      dplyr::mutate(
        request =
          list(
            httr2::req_options(
              request,
              timeout =
                max(
                  300,
                  curl::curl_options()["timeout"]
                )
            )
          )) |>
      dplyr::ungroup() |>
      dplyr::mutate(
        response = list(NULL),
        response = ifelse(force | !file.exists(file),
                          httr2::req_perform_parallel(
                            reqs = request[force | !file.exists(file)],
                            paths = file[force | !file.exists(file)],
                            on_error = "continue",
                            pool = curl::new_pool(host_con = workers)
                          ),
                          response),
        url = vapply(
          X = request,
          FUN = \(x){x$url},
          FUN.VALUE = "a"
        ),
        status =
          dplyr::case_when(
            vapply(
              X = response,
              FUN = is.null,
              FUN.VALUE = TRUE
            ) ~ "cached",
            vapply(
              X = response,
              FUN = inherits,
              FUN.VALUE = TRUE,
              what = "httr2_error") ~ "unavailable",
            .default = "downloaded"
          )
      ) |>
      dplyr::select(!c(request, response, path))
  }
