get_ncss <- function(x, out.path){

  if(file.exists(out.path))
    return(out.path)

  out <- httr::GET(x, httr::write_disk(out.path,
                                       overwrite = TRUE))
  return(out.path)
}

options(timeout = max(300, getOption("timeout")))

get_cmip6 <-
  function(x, outdir, workers = 10){
    x %<>%
      sf::st_transform(4326) %>%
      st_rotate() %>%
      sf::st_bbox() %>%
      as.list()

    clust <- multidplyr::new_cluster(workers)
    multidplyr::cluster_library(clust, "magrittr")
    multidplyr::cluster_copy(clust, c("get_ncss", "outdir"))

    out <-
      cmip6_files %>%
      dplyr::filter(!file.exists(file.path(outdir, dataset))) %>%
      dplyr::rowwise() %>%
      multidplyr::partition(clust) %>%
      dplyr::mutate(
        rast = get_ncss(
          x = httr::modify_url(
            paste0("https://ds.nccs.nasa.gov/thredds/ncss/grid/AMES/NEX/GDDP-CMIP6/",
                   model,"/",
                   scenario, "/",
                   run,"/",
                   element,"/",
                   dataset),
            query = list(
              var = element,
              north = x$ymax,
              west = x$xmin,
              east = x$xmax,
              south = x$ymin,
              disableProjSubset = "on",
              horizStride = 1,
              time_start = paste0(year, "-01-01"),
              time_end = paste0(as.integer(year) + 1, "-01-01"),
              timeStride = 1,
              addLatLon = TRUE
            )),
          out.path = file.path(outdir,
                               dataset))) %>%
      dplyr::collect()

    rm(clust)
    gc()
    gc()
    return(out)
  }
