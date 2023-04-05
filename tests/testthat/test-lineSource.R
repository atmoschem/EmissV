context("lineSource")

test_that("line emissions works", {

  s <- readRDS("sf.Rds")
  g <- gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d03"))

  a <- suppressWarnings( raster::cellStats(lineSource(s[1,],g,as_raster=TRUE),"sum") )
  b <- sum(lineSource(s[1,],g,as_raster=FALSE))

  expect_equal(a,1)
  expect_equal(b,1)

})
