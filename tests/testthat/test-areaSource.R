context("areaSource")

test_that("emissions with source by area", {
  expect_equal(areaSource(raster::shapefile(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"))[22,1],
                          raster::raster(paste0(system.file("extdata", package = "EmissV"),"/dmsp.tiff")),
                          gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d01"))),
               readRDS("data01.Rds"))

  expect_equal(areaSource(raster::shapefile(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"))[22,1],
                          raster::raster(paste0(system.file("extdata", package = "EmissV"),"/dmsp.tiff")),
                          gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d01")),
                          as_frac = T,name = "chururuba"),
               0.955761973247402)
})

# readRDS(paste0(system.file("tests", package = "EmissV"),"/data01.Rds"))
