library(terra)
library(sf)
library(rmapshaper)

cc <- rast("C:/Users/mcoghill/SynologyDrive/Cheatgrass/Model Outputs/2024/Kamloops_Lake_cover_class.tif")

# aggregate raster to 2.5m^2 for this to work (also for simpler output)
cc_ag <- aggregate(cc, fact = 5, fun = "median", na.rm = TRUE, cores = 0)
levels(cc_ag) <- levels(cc)
coltab(cc_ag) <- coltab(cc)
cc_vect <- as.polygons(cc_ag)
cc_poly <- st_as_sf(cc_vect)
cc_poly_simple <- ms_simplify(cc_poly)
st_write(cc_poly_simple, paste0("C:/Users/mcoghill/SynologyDrive/Cheatgrass/Model Outputs/2024/Shapefile/Kamloops_Lake_cover_class.shp"),
         quiet = TRUE, delete_dsn = TRUE)
