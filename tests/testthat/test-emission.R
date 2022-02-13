context("emission")

test_that("emission function works", {

  g          <- gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d01"))
  g$map_proj <- 2 # using old method

  expect_equal(emission(total = totalEmission(vehicles(example = TRUE,verbose = F),
                                      emissionFactor(example = TRUE,verbose = F),
                                      pol = c("CO"),verbose = T),
                        pol = "FISH",
                        area = list(SP = areaSource(raster::shapefile(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"))[22,1],
                                             raster::raster(paste0(system.file("extdata", package = "EmissV"),"/dmsp.tiff")),
                                             g,
                                             name = "SP",verbose = F),
                             RJ = areaSource(raster::shapefile(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"))[17,1],
                                             raster::raster(paste0(system.file("extdata", package = "EmissV"),"/dmsp.tiff")),
                                             g,
                                             name = "RJ",verbose = F)),
                        grid = g,
                        verbose = F),
               cat(paste("FISH","not found in total !\n")))

  expect_equal(sum(emission(total = totalEmission(vehicles(example = TRUE,verbose = F),
                                          emissionFactor(example = TRUE,verbose = F),
                                          pol = c("CO"),verbose = T),
                            pol = "CO",
                            area = list(SP = areaSource(raster::shapefile(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"))[22,1],
                                                 raster::raster(paste0(system.file("extdata", package = "EmissV"),"/dmsp.tiff")),
                                                 g,
                                                 name = "SP",verbose = F),
                                 RJ = areaSource(raster::shapefile(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"))[17,1],
                                                 raster::raster(paste0(system.file("extdata", package = "EmissV"),"/dmsp.tiff")),
                                                 g,
                                                 name = "RJ",verbose = F)),
                            grid = g,
                            mm=28,
                            verbose = T,
                            aerosol = T,
                            plot = T)
  ),
  units::as_units(361.41688129791686, "ug*m^-2*s^-1"))

  # g$map_proj <- 1 # using new method

  expect_equal(sum(emission(total = totalEmission(vehicles(example = TRUE,verbose = F),
                                          emissionFactor(example = TRUE,verbose = F),
                                          pol = c("CO"),verbose = F),
                            pol = "CO",
                            area = list(SP = areaSource(raster::shapefile(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"))[17,1],
                                                        raster::raster(paste0(system.file("extdata", package = "EmissV"),"/dmsp.tiff")),
                                                        g,
                                                        name = "SP",verbose = F)),
                            grid = g,
                            mm=28,
                            verbose = T,
                            aerosol = F,
                            plot = T)
  ) > units::as_units(1, "ug*m^-2*s^-1"),
  TRUE)

  g   <- gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d01"))
  ed  <- read("edgar_co_test.nc",version = "EDGAR")
  a   <- emission(inventory = ed,grid = g,plot = T,verbose = T, pol = 'FISH', mm = 2)
  b   <- emission(inventory = ed,grid = g,plot = T,verbose = T,aerosol = T, mm = 2)

  expect_equal(nrow(a),nrow(b))
})
