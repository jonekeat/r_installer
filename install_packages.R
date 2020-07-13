required_packages <- c("disk.frame", "tsibble")

install_packages <- function(pkgs, 
                             repos = getOption("repos", "https://cran.rstudio.com/"),
                             ...) {
  # Get all loaded & attched pkgs in fresh session 
  loaded_pkg <- loadedNamespaces()
  # attached_pkg <- .packages()
  
  # Warn if non-base pkgs are loaded before installation
  installed_pkg <- installed.packages()
  base_pkg <- subset(as.data.frame(installed_pkg, stringsAsFactors = FALSE), 
                     Priority == "base", select = Package)
  base_pkg <- unique(base_pkg[[1L]])
  non_base_loaded <- !loaded_pkg %in% base_pkg
  if (any(non_base_loaded))
    warning("Some non-base packages are loaded before installation: '", 
            paste0(loaded_pkg[non_base_loaded], collapse = "', '"), 
            "'. Installing these packages might caused installation failed", 
            ", try run 'rm(list = ls())' & launch a new R session\n", immediate. = TRUE)
  
  # Redirect installation path from system lib to avoid mixing with base pkgs in Windows
  if (.Platform$OS.type == "windows") {
    r_version <- paste0(R.version$major, ".", substr(R.version$minor, 1, 1))
    win_lib <- paste0(dirname(normalizePath(Sys.getenv("R_HOME"), "/")), "/win-library/", 
                      r_version)
    if (!dir.exists(win_lib))
      dir.create(win_lib, recursive = TRUE)
    .libPaths(win_lib)
  }
  
  # Install binary whenever possible
  opt <- c(options(install.packages.compile.from.source = "never"), options(warn = -1))
  on.exit(options(opt))
  
  # Check if package exist
  pkg_exist <- pkgs %in% installed_pkg[, "Package"]
  
  # # Check if pkgs exist & can be loaded & attached properly
  # pkg_exist <- unlist(lapply(pkgs, require, quietly = TRUE, 
  #                            warn.conflicts = FALSE, character.only = TRUE))
  # 
  # # Detach & unload all checked pkgs before installation
  # pkg_to_unload <- setdiff(loadedNamespaces(), loaded_pkg)
  # init <- Sys.time()
  # while(length(pkg_to_unload) > 0L) {
  #   if (as.numeric(difftime(Sys.time(), init, units = "sec")) > timeout)
  #     stop("timeout issue: unable to unload all loaded namespaces before package installation")
  #   lapply(pkg_to_unload, FUN = function(pkg) try(unloadNamespace(pkg), silent = TRUE))
  #   pkg_to_unload <- setdiff(loadedNamespaces(), loaded_pkg)
  # }
  # pkg_to_detach <- setdiff(.packages(), attached_pkg)
  # if (length(pkg_to_detach))
  #   lapply(pkg_to_detach, detach, name = paste0("package:", pkg_to_detach), 
  #          character.only = TRUE, force = TRUE)
  
  # Only install missing pkgs
  if (any(pkg_exist))
    message("'", paste0(pkgs[pkg_exist], collapse = "', '"),
            "' already installed and will be skipped. ", 
            "If you want to re-install these packages, ", 
            "try remove it first and re-run again\n")
  pkg_to_install <- pkgs[!pkg_exist]
  if (length(pkg_to_install))
    install.packages(pkg_to_install, repos = repos, ...)
  return(invisible(NULL))
}
