#' @import utils
utils::globalVariables(
  c(
    "dataset",
    "element",
    "model",
    "path",
    "rast",
    "run",
    "scenario",
    "year"
  )
)

#' Change a simple feature from \[-180,180) longitude to \[0,360) longitude
#'
#' @param x An [`sf`] object.
#'
#' @return A rotate [`sf`] object.
st_rotate <- function(x) {
  x2 <- (sf::st_geometry(x) + c(360, 90)) %% c(360) - c(0, 90)
  x3 <- sf::st_wrap_dateline(sf::st_set_crs(x2 - c(180, 0), 4326)) + c(180, 0)
  x4 <- sf::st_set_crs(x3, 4326)

  x <- sf::st_set_geometry(x, x4)

  return(x)
}

#' Download a file using httr2
#'
#' @param url A URL to download.
#' @param out.path A path to which to write the downloaded file.
#' @param force Whether to overwrite the file if it exists.
#'
#' @return The path of the downloaded file.
download_file <-
  function(
      url,
      out.path,
      force) {
    if (!force && file.exists(out.path)) {
      return(out.path)
    }

    httr2::request(url) |>
      httr2::req_options(
        timeout =
          max(
            300,
            curl::curl_options()["timeout"]
          )
      ) |>
      httr2::req_perform(
        path = out.path,
        verbosity = 0
      )
    return(out.path)
  }
