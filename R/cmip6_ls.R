#' List the available NASA NEX-GDDP-CMIP6 data
#'
#' `cmip6_ls()` lists all data, removing legacy versions of the data by default.
#' `cmip6_ls_models()` lists the available models. `cmip6_ls_scenarios()` lists
#' the available scenarios (shared socioeconomic pathways, and the historical
#' runs). `cmip6_ls_elements()` lists the available elements.
#'
#' @param latest Whether to remove legacy versions of the data where
#' new data exist. Defaults to TRUE.
#'
#' @return A [`tibble::tbl_df`] listing the available data.
#' @source <https://nex-gddp-cmip6.s3.us-west-2.amazonaws.com/index.html>
#' @export
#'
#' @examples
#' cmip6_ls()
cmip6_ls <- function(latest = TRUE) {
  cmip6::cmip6 |>
    {
      \(.) if (latest) {
        dplyr::distinct(., model, scenario, run, year, element, .keep_all = TRUE)
      } else {
        .
      }
    }()
}

#' @rdname cmip6_ls
#' @export
cmip6_ls_models <-
  function() {
    cmip6_ls()$model |>
      levels()
  }

#' @rdname cmip6_ls
#' @export
cmip6_ls_scenarios <-
  function() {
    cmip6_ls()$scenario |>
      levels()
  }

#' @rdname cmip6_ls
#' @export
cmip6_ls_elements <-
  function() {
    cmip6_ls()$element |>
      levels()
  }
