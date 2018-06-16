context("emission")

test_that("final emission works", {
  expect_equal(sum(emission(totalEmission(vehicles(example = TRUE,verbose = F),
                                          emissionFactor(example = TRUE,verbose = F),
                                          pol = c("CO"),verbose = F),
                            "CO",
                            list(SP = areaSource(raster::shapefile(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"))[22,1],
                                                 raster::raster(paste0(system.file("extdata", package = "EmissV"),"/dmsp.tiff")),
                                                 gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d01")),
                                                 name = "SP",verbose = F),
                                 RJ = areaSource(raster::shapefile(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"))[17,1],
                                                 raster::raster(paste0(system.file("extdata", package = "EmissV"),"/dmsp.tiff")),
                                                 gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d01")),
                                                 name = "RJ",verbose = F)),
                            gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d01"),verbose = F),
                            mm=28,
                            verbose = F,
                            aerosol = T,
                            plot = T)
  ),
  units::as_units(362.58086806097963972206343896687030792236328125, "ug*m^-2*s^-1"))

  expect_equal(sum(emission(totalEmission(vehicles(example = TRUE,verbose = F),
                                          emissionFactor(example = TRUE,verbose = F),
                                          pol = c("CO"),verbose = F),
                            "CO",
                            list(SP = areaSource(raster::shapefile(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"))[22,1],
                                                 raster::raster(paste0(system.file("extdata", package = "EmissV"),"/dmsp.tiff")),
                                                 gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d01")),
                                                 name = "SP",verbose = F)),
                            gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d01"),verbose = F),
                            mm=28,
                            verbose = F,
                            aerosol = F,
                            plot = T)
  ),
  units::as_units(39419.0995366892966558225452899932861328125, "MOL*km^-2*h^-1"))
})