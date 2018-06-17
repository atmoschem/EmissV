context("rasterSource")

test_that("emissions with levels works!", {
  expect_equal(rasterSource(raster::raster(paste0(system.file("extdata", package = "EmissV"),"/dmsp.tiff")),
                            gridInfo("vertical.nc",z=T)),
               rasterSource(raster::raster(paste0(system.file("extdata", package = "EmissV"),"/dmsp.tiff")),nlevels = 30,
                            gridInfo("vertical.nc",z=T)))

})
