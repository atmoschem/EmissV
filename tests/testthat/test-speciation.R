context("test-speciation")

test_that("speciation works", {

  veic <- vehicles(example = TRUE)
  EmissionFactors <- emissionFactor(example = TRUE)
  TOTAL <- totalEmission(veic,EmissionFactors,pol = "PM")
  pm_iag <- c(E_PM25I = 0.0509200,
              E_PM25J = 0.1527600,
              E_ECI   = 0.1196620,
              E_ECJ   = 0.0076380,
              E_ORGI  = 0.0534660,
              E_ORGJ  = 0.2279340,
              E_SO4I  = 0.0063784,
              E_SO4J  = 0.0405216,
              E_NO3J  = 0.0024656,
              E_NO3I  = 0.0082544,
              E_PM10  = 0.3300000)
  PM <- speciation(TOTAL,pm_iag)

  expect_equal( length(PM),
                11 )
})
