context("emissionFactors")

test_that("emissionFactors works!", {
  expect_equal(emissionFactor(example = TRUE),
               emissionFactor(ef = list(CO = c(1.75,10.04,0.39,0.45,0.77,1.48,1.61,0.75),
                                        PM = c(0.0013,0.0,0.0010,0.0612,0.1052,0.1693,0.0,0.0)),
                              vnames = c("Light Duty Vehicles Gasohol","Light Duty Vehicles Ethanol",
                                         "Light Duty Vehicles Flex","Diesel Trucks",
                                         "Diesel Urban Busses","Diesel Intercity Busses",
                                         "Gasohol Motorcycles",
                                         "Flex Motorcycles")))

})
