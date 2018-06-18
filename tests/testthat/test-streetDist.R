context("streetDist")

test_that("funcion muy loca", {
  expect_equal(dim(suppressWarnings( streetDist(emission = 1000000,epsg = 31983,
                                                grid = readRDS("g.Rds"),
                                                osm  = readRDS("streets.Rds"))) ),
               c(6960,3))

  expect_equal(dim(suppressWarnings( streetDist(emission = 1000000,epsg = NULL,
                                                grid = readRDS("g.Rds"),
                                                osm  = readRDS("streets.Rds"))) ),
               c(6960,3))
})
