context("lineSource")

test_that("line emissions works", {

  osm <- read(paste(system.file("extdata",package="EmissV"),"/streets.osm.xz",sep=""),"osm")
  g   <- gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d03"))

  expect_equal(raster::cellStats(lineSource(osm,g,as_raster=TRUE),"sum"),
               sum(lineSource(osm,g,as_raster=FALSE)))
})
