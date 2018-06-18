context("lineSource")

test_that("line emissions works", {

  s <- readRDS("sf.Rds")
  g <- gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d03"))

  expect_equal(raster::cellStats(lineSource(s,g,as_raster=TRUE),"sum"),1)
  expect_equal(sum(lineSource(s,g,as_raster=FALSE)),1)

})
