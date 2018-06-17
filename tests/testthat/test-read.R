context("read")

test_that("read edgar works", {
  expect_equal(dim(read("edgar_co_test.nc",as_raster = F)),
               c(36,18))
})
