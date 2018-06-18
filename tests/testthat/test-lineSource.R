context("lineSource")

test_that("line emissions works", {
    expect_equal(raster::cellStats(lineSource(readRDS("sf.Rds"),
                                            gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d03")),
                                            as_raster=TRUE),"sum"),
               1
               )

  expect_equal(1,
               sum(lineSource(readRDS("sf.Rds"),
                              gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d03")),
                              as_raster=FALSE))
  )

})
