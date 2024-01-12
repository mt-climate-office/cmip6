## code to prepare `cmip6_ls` dataset goes here
cmip6 <-
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
  dplyr::select(model, scenario, run, element, year, version, dataset, path = fileURL) |>
  dplyr::arrange(model, scenario, run, element, year, dplyr::desc(version)) |>
  dplyr::mutate(
    model = factor(model),
    scenario = factor(scenario, ordered = TRUE),
    year = as.integer(year),
    element = factor(element),
    version = factor(version, ordered = TRUE)
  )

usethis::use_data(cmip6, overwrite = TRUE)
