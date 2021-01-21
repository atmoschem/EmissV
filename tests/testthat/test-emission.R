context("emission")

test_that("final emission works", {

  g          <- gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d01"))
  g$map_proj <- 2 # using old method

  expect_equal(emission(totalEmission(vehicles(example = TRUE,verbose = F),
                                      emissionFactor(example = TRUE,verbose = F),
                                      pol = c("CO"),verbose = T),
                        "FISH",
                        list(SP = areaSource(raster::shapefile(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"))[22,1],
                                             raster::raster(paste0(system.file("extdata", package = "EmissV"),"/dmsp.tiff")),
                                             g,
                                             name = "SP",verbose = F),
                             RJ = areaSource(raster::shapefile(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"))[17,1],
                                             raster::raster(paste0(system.file("extdata", package = "EmissV"),"/dmsp.tiff")),
                                             g,
                                             name = "RJ",verbose = F)),
                        g,
                        verbose = F),
               cat(paste("FISH","not found in total !\n")))

  expect_equal(sum(emission(totalEmission(vehicles(example = TRUE,verbose = F),
                                          emissionFactor(example = TRUE,verbose = F),
                                          pol = c("CO"),verbose = T),
                            "CO",
                            list(SP = areaSource(raster::shapefile(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"))[22,1],
                                                 raster::raster(paste0(system.file("extdata", package = "EmissV"),"/dmsp.tiff")),
                                                 g,
                                                 name = "SP",verbose = F),
                                 RJ = areaSource(raster::shapefile(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"))[17,1],
                                                 raster::raster(paste0(system.file("extdata", package = "EmissV"),"/dmsp.tiff")),
                                                 g,
                                                 name = "RJ",verbose = F)),
                            g,
                            mm=28,
                            verbose = T,
                            aerosol = T,
                            plot = T)
  ),
  units::as_units(361.41688129791686, "ug*m^-2*s^-1"))

  # g$map_proj <- 1 # using new method

  expect_equal(sum(emission(totalEmission(vehicles(example = TRUE,verbose = F),
                                          emissionFactor(example = TRUE,verbose = F),
                                          pol = c("CO"),verbose = F),
                            "CO",
                            list(SP = areaSource(raster::shapefile(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"))[17,1],
                                                 raster::raster(paste0(system.file("extdata", package = "EmissV"),"/dmsp.tiff")),
                                                 g,
                                                 name = "SP",verbose = F)),
                            g,
                            mm=28,
                            verbose = T,
                            aerosol = F,
                            plot = T)
  ) > units::as_units(1, "ug*m^-2*s^-1"),
  TRUE)

  expect_equal(nrow(emission(inventory = read("edgar_co_test.nc"),pol = "FISH",
                            grid = g,
                            mm=1,plot = T,verbose = T)
  ),
  nrow(emission(inventory = read("edgar_co_test.nc"),pol = "FISH",
               grid = g,
               mm=1,plot = T, aerosol = T)
  ))
})
