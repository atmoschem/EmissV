context("vehicles")

test_that("vehicle probability works!", {
  expect_equal(sum(vehicles(600,"S_LOURENCO_DO_SUL",distribution = c(0.5,0.5,1,1,1.5,1.5),
                            type = c("LDV", "LDV", "LDV","TRUCKS","BUS","BUS"),
                            fuel = c("E25", "E100", "FLEX","B5","B5","B5"))$S_LOURENCO_DO_SUL), 600)
})


# v <- vehicles(600,"S_LOURENCO_DO_SUL",distribution = c(0.5,0.5,1,1,1.5,1.5),
#               type = c("LDV", "LDV", "LDV","TRUCKS","BUS","BUS"),
#               fuel = c("E25", "E100", "FLEX","B5","B5","B5"))
# sum(v$S_LOURENCO_DO_SUL)
