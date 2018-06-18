context("lineSource")

test_that("line emissions works", {

  s <- readRDS("sf.Rds")
  print(getwd())
  g <- gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d03"))

  expect_equal(1,sum(lineSource(s,g,as_raster=FALSE)))
  expect_equal(raster::cellStats(lineSource(s,g,as_raster=TRUE),"sum"),1)

})
