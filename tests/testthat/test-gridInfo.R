context("gridInfo")

test_that("multiplication works", {
  expect_equal(dim(gridInfo("vertical.nc",z=T)$Levels),
               c(4,4,30))
})

# grid <- gridInfo("C:/Users/Schuch/Documents/EmissV/tests/testthat/vertical.nc",z = T)
