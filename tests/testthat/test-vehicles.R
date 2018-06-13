context("vehicles")

test_that("vehicle probability works!", {
  expect_equal(sum(vehicles(example = T)$SP), vehicles(27332097,"SP",1,"LDV","B5")$SP)
})
