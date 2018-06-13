context("vehicles")

test_that("vehicle probability works!", {
  expect_equal(sum(vehicles(example = T)$SP), 27332097)
})



# TEST !!!!
