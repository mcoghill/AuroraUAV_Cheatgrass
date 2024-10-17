zips <- list.files("C:/Users/matth/Downloads", pattern = "^DEM_", full.names = TRUE)
zips <- grep(".zip", zips, value = TRUE)
outdir <- file.path("C:/Users/matth/Downloads/Kamloops_DEM")
dir.create(outdir, showWarnings = FALSE)

lapply(zips, function(x) {
  fl <- unzip(x, list = TRUE)$Name
  fl <- grep("/", fl, value = TRUE)
  # pat1 <- gsub(".*_","", x)
  # pat2 <- paste0(gsub(".zip", "", pat1), "_DEM/")
  # pat3 <- paste0(pat2, "_DEM/w001001.adf")
  f <- unzip(x, fl, exdir = outdir, overwrite = TRUE)
  # file.rename(file.path(outdir, "w001001.adf"), file.path(outdir, paste0(pat2, ".adf")))
})

library(terra)
r <- sprc(dir(outdir, full.names = TRUE))
m <- mosaic(r)
writeRaster(m, "C:/Users/matth/Downloads/Kamloops_DEM/Kamloops_DEM.tif", overwrite = TRUE)

library(tidyverse)
library(terra)
library(sf)
library(rmapshaper)

cc <- rast("C:/Users/matth/SynologyDrive/Cheatgrass/Model Outputs/2024/Kamloops_Lake_cover_class.tif")
cc_poly <- terra::as.polygons(cc) %>% 
  st_as_sf()

st_write(cc_poly, "C:/Users/matth/Downloads/cc_poly.gpkg")
cc_poly <- st_read("C:/Users/matth/Downloads/cc_poly.gpkg", quiet = TRUE)
cc_val <- st_make_valid(cc_poly)
cc_poly_simple <- ms_simplify(cc_poly, keep = 0.05)