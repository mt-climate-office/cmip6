#' Title
#'
#' @param outdir
#' @param aoi
#' @param models
#' @param scenarios
#' @param elements
#' @param years
#' @param latest
#' @param workers
#' @param force
#'
#' @return
#' @export
#'
#' @examples
cmip6_dl <-
  function(
    outdir = getwd(),
    aoi = NULL,
    models = NULL,
    scenarios = NULL,
    elements = NULL,
    years = NULL,
    latest = TRUE,
    workers = 10,
    force = FALSE
  ){
    # Create the output directory, recursively if necessary
    dir.create(outdir,
               recursive = TRUE,
               showWarnings = FALSE)

    plan <-
      cmip6_ls(latest = latest) %>%
      dplyr::filter(
        if (!is.null(models)) (model %in% models) else (1==1),
        if (!is.null(scenarios)) (scenario %in% scenarios) else (1==1),
        if (!is.null(elements)) (element %in% elements) else (1==1),
        if (!is.null(years)) (year %in% years) else (1==1)
      )

    if(is.null(aoi)){
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
      cmip6_dl_tds(aoi = aoi,
                   plan = plan,
                   outdir = outdir,
                   workers = workers,
                   force = force)
    )

  }
