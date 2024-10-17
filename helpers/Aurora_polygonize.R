library(terra)
library(sf)
library(sfheaders)
library(Rsagacmd)

saga_cmd_path <- file.path("C:/SAGA-GIS/saga-9.2.0_x64/saga_cmd.exe")
saga <- saga_gis(saga_cmd_path, raster_backend = "terra", raster_format = "GeoTIFF")

altum_prob <- rast("C:/Users/matth/SynologyDrive/Cheatgrass/Model Outputs/Altum_Prob.tif")
m3m_prob <- rast("C:/Users/matth/SynologyDrive/Cheatgrass/Model Outputs/M3M_Prob.tif")

prob <- saga$grid_tools$mosaicking(grids = list(altum_prob, m3m_prob), 
                                   name = "prob_merged.tif", overlap = 6,
                                   match = 2)

prob_tmp <- prob*0
prob_tmp <- writeRaster(prob_tmp, file.path(tempdir(), "prob_tmp.tif"), datatype = "INT1U", overwrite = TRUE)
prob_shp <- sf_remove_holes(st_as_sf(fillHoles(as.polygons(prob_tmp))))

prob_filled <- saga$grid_tools$close_gaps_with_stepwise_resampling(
  prob, result = file.path(tempdir(), "prob_merged_filled.tif"))

prob_filled_msk <- mask(prob_filled, vect(prob_shp), filename = file.path(tempdir(), "prob_filled_masked.tif"), overwrite = TRUE)

# reclassify grid
m <- c(0, 0.2, 1,
       0.2, 0.4, 2,
       0.4, 0.6, 3,
       0.6, 0.8, 4,
       0.8, 1, 5)
rclmat <- matrix(m, ncol=3, byrow=TRUE)
prob_class <- classify(prob_filled_msk, rclmat, include.lowest = TRUE, filename = file.path(
  tempdir(), "prob_classified.tif"), datatype = "INT1U", overwrite = TRUE)

prob_smoothed <- saga$grid_filter$majority_minority_filter(
  prob_class, result = file.path(tempdir(), "prob_filled.tif"),
  type = 0, kernel_type = 0)

prob_cln <- saga$grid_filter$sieve_and_clump(
  prob_smoothed, filtered = file.path(tempdir(), "prob_cleaned.tif"), mode = 1, .verbose = T)

levs <- data.frame(id = 1:5, probability = c("Very Low Probability (0-20%)", "Low Probability (20-40%)", "Moderate Probability (40-60%)", "High Probability (60-80%)", "Very High Probability (80-100%)"))
levels(prob_cln) <- levs
prob_poly <- as.polygons(prob_cln)

prob_poly_simp <- simplifyGeom(prob_poly, tolerance = 1)

# mask to match shape of cover classes
class_shp <- vect("C:/Users/matth/SynologyDrive/Cheatgrass/Model Outputs/Cover_Class_simplified.shp")
class_union <- aggregate(class_shp)
class_holes <- fillHoles(class_union, inverse = TRUE) |> st_as_sf() |> st_as_sfc() |> st_cast("POLYGON")
holes <- as.numeric(st_area(class_holes))
holes_lg_v <- class_holes[which(holes > 10)] |> st_coordinates()
holes_lg_v[, "L1"] <- holes_lg_v[, "L1"] + 1
prob_shp_v <- st_as_sfc(prob_shp) |> st_cast("POLYGON") |> st_coordinates()
prob_shp_v[, "L2"] <- prob_shp_v[, "L2"] + length(unique(holes_lg_v[, "L2"]))
prob_bind <- rbind(holes_lg_v, prob_shp_v)

prob_shp_new <- lapply(unique(prob_bind[, "L2"]), function(x) {
  prob_bind[prob_bind[, "L2"] == x, c("X", "Y")]
}) |> st_polygon() |> st_sfc(crs = st_crs(prob_shp)) 

holes_lg_shp <- class_holes[which(holes > 10)]
holes_lg_shp_merge <- st_union(holes_lg_shp)
prob_shp_2 <- st_as_sfc(prob_shp) |> st_cast("POLYGON")
aaa <- st_as_sf(prob_poly_simp)
aab <- st_difference(aaa, holes_lg_shp_merge)

st_write(aaa, file.path(tempdir(), "poly.gpkg"), delete_dsn = TRUE)
st_write(holes_lg_shp_merge, file.path(tempdir(), "holes.gpkg"), delete_dsn = TRUE)


# prob_poly_msk <- prob_poly_simp - vect(prob_shp_new)

# writeVector(prob_poly_msk, file.path(tempdir(), "Probability_simplified3.shp"))
