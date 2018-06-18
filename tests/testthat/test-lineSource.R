<<<<<<< HEAD
# context("lineSource")
#
# test_that("line emissions works", {
#     expect_equal(raster::cellStats(lineSource(readRDS("sf.Rds"),
#                                             gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d03")),
#                                             as_raster=TRUE),"sum"),
#                sum(lineSource(readRDS("sf.Rds"),
#                               gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d03")),
#                               as_raster=FALSE))
#                )
# })
=======
context("lineSource")

test_that("line emissions works", {
    expect_equal(raster::cellStats(lineSource(readRDS("sf.Rds"),
                                            gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d03")),
                                            as_raster=TRUE),"sum"),
               sum(lineSource(readRDS("sf.Rds"),
                              gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d03")),
                              as_raster=FALSE))
               )
})
>>>>>>> ca0b215f30eb603c94e39ce1bb5346123dab565b
