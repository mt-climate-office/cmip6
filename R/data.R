#' Available NASA NEX-GDDP-CMIP6 Data
#'
#' A [`tibble::tbl_df`] listing the available NASA NEX-GDDP-CMIP6 data.
#'
#' @format ## `cmip6`
#' A data frame with 138,930 rows and 8 columns:
#' \describe{
#'   \item{model}{Model name}
#'   \item{scenario}{Scenario (shared socioeconomic pathway) identifier}
#'   \item{run}{Model variant reported}
#'   \item{year}{Calendar year}
#'   \item{element}{Meteorological variable}
#'   \item{version}{NASA NEX-GDDP-CMIP6 file version}
#'   \item{dataset}{File name}
#'   \item{path}{Path of the dataset in the NCCS THREDDS Data Catalog or
#'   the NASA NEX-GDDP-CMIP6 AWS archive}
#' }
#' @source <https://nex-gddp-cmip6.s3.us-west-2.amazonaws.com/index.html>
"cmip6"
