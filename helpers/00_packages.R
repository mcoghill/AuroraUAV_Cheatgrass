# Make sure you have all of these packages and their dependencies installed
# before starting!

# CRAN packages
ls <- c("tidyverse", "lidR", "sf", "sfheaders", "future.apply", "terra", 
  "data.table", "units", "rmapshaper", "lwgeom", "RCSF", "lme4", "devtools",
  "rstoolbox", "mlr3verse", "mlr3spatial", "mlr3spatiotempcv", "readxl",
  "rsagacmd")

new_packages <- ls[!(ls %in% installed.packages()[, "Package"])]
if(length(new_packages)) install.packages(new_packages)

# ClimateNAr package
# First, check if ClimateNAr is already installed and up to date.
if("ClimateNAr" %in% rownames(installed.packages())) {
  if(as.Date("2024-10-01") <= packageDate("ClimateNAr")) {
    i <- FALSE
  } else i <- TRUE
} else i <- TRUE

# Download the ClimateNAr package if needed. It is not on CRAN, so you will need
# to make sure that you can download it either through this link, or create
# an account and download it there. Link for the package download:
if(i) {
  options(timeout = Inf)
  url <- "https://climatena.ca/downloads/ClimateNAr.zip"
  dl_path <- file.path(tempdir(), "ClimateNAr.zip")
  download.file(url, destfile = dl_path)
  
  # Next, unzip the file into your R package installation folder
  install.packages(dl_path, repos = NULL, type = "source")
}

# Install my custom lidR function
# devtools::install_github("mcoghill/lidR.li2012enhancement")

# SAGA GIS - Choose version (check at https://sourceforge.net/projects/saga-gis/)
saga_ver <- "9.6.0"
url <- paste0("https://sourceforge.net/projects/saga-gis/files/SAGA%20-%20",
              strsplit(saga_ver, "\\.")[[1]][1], "/SAGA%20-%20",
              saga_ver, "/saga-", saga_ver, "_x64.zip/")
saga_dir <- file.path("C:/SAGA-GIS")
dir.create(saga_dir, showWarnings = FALSE)
saga_zip <- file.path(saga_dir, paste0("saga-", saga_ver, "_x64.zip"))
download.file(url, saga_zip, mode = "wb") # mode argument only needed on Windows
unzip(saga_zip, exdir = saga_dir)
unlink(saga_zip)
