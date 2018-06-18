context("streetDist")

test_that("funcion muy loca", {
  expect_equal(dim(suppressWarnings(  streetDist(emission = 1000000,
                                                 grid = readRDS("g.Rds"),
                                                 osm  = readRDS("streets.Rds"))) ),
               c(6960,3))
})
