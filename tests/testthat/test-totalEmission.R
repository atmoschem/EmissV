context("totalEmission")

test_that("total emission calcualtions", {
  expect_equal(totalEmission(vehicles(example = T,verbose = F),
                             emissionFactor(example = T,verbose = F),
                             pol = c("CO","PM"),verbose = F)$CO[[1]],
               units::set_units(2244973629, "g/d"))
})
