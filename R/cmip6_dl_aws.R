#' Download NASA NEX-GDDP-CMIP6 data from Amazon Web Services
#'
#' @param plan
#' @param outdir
#' @param workers
#' @param force
#'
#' @return A [`tibble::tbl_df`] listing the downloaded data.
#' @export
#'
#' @examples
cmip6_dl_aws <-
  function(
    plan,
    outdir,
    workers,
    force
  ){
    # Checks
    checkmate::assert_data_frame(plan)
    checkmate::assert_directory_exists(outdir)
    checkmate::assert_int(workers)
    checkmate::assert_logical(force)

    clust <- multidplyr::new_cluster(workers)
    multidplyr::cluster_library(clust, c("magrittr"))
    multidplyr::cluster_copy(clust, c("get_aws", "force"))

    out <-
      plan %>%
      dplyr::mutate(rast = file.path(outdir,
                                     dataset)) %>%
      dplyr::rowwise() %>%
      multidplyr::partition(clust) %>%
      dplyr::mutate(
        rast = #tryCatch(
          get_aws(
            x = path,
            out.path = rast,
            force = force)#,
          #error = function(e){return(NA)}
#
#         )
      ) %>%
      dplyr::collect()

    rm(clust)

    return(out)
  }

#' Title
#'
#' @param x
#' @param out.path
#' @param force
#'
#' @return
#' @internal
get_aws <-
  function(x,
           out.path,
           force){

    if(!force && file.exists(out.path))
      return(out.path)

    file.path("https://nex-gddp-cmip6.s3-us-west-2.amazonaws.com", x) %>%
      httr2::request() %>%
      httr2::req_perform(path = out.path,
                         verbosity = 0)

    return(out.path)
  }
