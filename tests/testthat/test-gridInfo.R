context("gridInfo")

test_that("multiplication works", {
  expect_equal(dim(gridInfo("vertical.nc",z=T)$Levels),
               c(4,4,30))
})
