#' List the available NASA NEX-GDDP-CMIP6 data
#'
#' @param latest Whether to remove legacy versions of the data where
#' new ones exist. Defaults to TRUE.
#'
#' @return A [`tibble::tbl_df`] listing the available data.
#' @export
#'
#' @examples
#' cmip6_ls()
cmip6_ls <- function(latest = TRUE) {
    rbind(
      read.table("https://nex-gddp-cmip6.s3-us-west-2.amazonaws.com/index_v1.1_md5.txt",
                     col.names = c("md5", "fileURL")
    ),
      read.table("https://nex-gddp-cmip6.s3-us-west-2.amazonaws.com/index_md5.txt",
        col.names = c("md5", "fileURL")
      )
    ) |>
    dplyr::mutate(dataset = tools::file_path_sans_ext(basename(fileURL))) |>
    tidyr::separate_wider_delim(dataset,
      names = c("element", "timestep", "model", "scenario", "run", "type", "year", "version"),
      delim = "_",
      cols_remove = FALSE,
      too_few = "align_start"
    ) |>
    dplyr::mutate(
      dataset = paste0(dataset, ".nc"),
      version = tidyr::replace_na(version, "v1.0")
    ) |>
    dplyr::select(model, scenario, run, year, element, dataset, version, path = fileURL) |>
    dplyr::arrange(model, scenario, run, year, element, dplyr::desc(version)) |>
    {\(.) if(latest)
      dplyr::distinct(., model, scenario, run, year, element, .keep_all = TRUE)
      else . }()

}
