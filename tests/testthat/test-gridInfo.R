context("gridInfo")

test_that("multiplication works", {
  expect_equal(dim(gridInfo("vertical.nc",z=T)$z),
               c(4,4,30))
})
