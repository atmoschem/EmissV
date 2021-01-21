context("rasterSource")

test_that("emissions with levels works!", {

  g          <- gridInfo("vertical.nc",z=T)
  g$map_proj <- 2 # using old method
  r_file     <- paste0(system.file("extdata", package = "EmissV"),"/dmsp.tiff")

  expect_equal(rasterSource(raster::raster(r_file),nlevels = 'all',g),
               rasterSource(raster::raster(r_file),nlevels = 30 ,  g) )

})
