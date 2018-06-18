context("lineSource")

test_that("line emissions works", {
  expect_equal(raster::cellStats(lineSource(read(paste(system.file("extdata",package="EmissV"),"/streets.osm.xz",sep=""),"osm"),
                                            gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d03")),
                                            as_raster=TRUE),"sum"),
               sum(lineSource(read(paste(system.file("extdata",package="EmissV"),"/streets.osm.xz",sep=""),"osm"),
                              gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d03")),
                              as_raster=FALSE)))
})
