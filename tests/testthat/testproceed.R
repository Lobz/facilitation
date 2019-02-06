# Test for #57
# Test for #53
# Test for #52
# Test for #49
library(facilitation)
context("Proceed")

test_that("Basic proceed usage", {
  ratesA <- matrix(c(0,0,1),nrow=1)
  ratesB <- matrix(c(0.01,0,0,0,0.1,0.1),nrow=2)
  resultsA <- community(maxtime=2.96,numstages=1,parameters=ratesA,init=20, height=81, width=72)
  resultsB <- community(maxtime=1.76,numstages=c(1,1),parameters=ratesB,init=c(15,10), boundary="absortive")

  procA <- proceed(resultsA, 1.04)
  procB <- proceed(resultsB, 1.24)

  expect_equal(class(procA), "list")
  expect_equal(names(procA), c("data","num.pop","num.total","num.stages","maxtime","interactions","param","slopeFunction","init","height","width","boundary","dispKernel"))
  expect_equal(names(procA$data), c("sp","id","x","y","begintime","endtime"))
  expect(all(procA$data$sp == 1), "Wrong sp labels")
  expect(any(procB$data$sp == 2), "Wrong sp labels")
  expect(all(procA$data$id >= 0), "Wrong id labels")
  expect(all(procB$data$id >= 0), "Wrong id labels")
  # See issue #25
  expect(any(procA$data$id == 0), "Wrong id labels")
  expect(any(procB$data$id == 0), "Wrong id labels")
  expect(nrow(procA$data) > 30, "Too few data lines")
  # Passed arguments should be returned
  expect_equal(procA$width, 72)
  expect_equal(procA$height, 81)
  expect_equal(procB$boundary, "absortive")
  expect_equal(procB$num.stages, c(1,1))
  expect_equal(procA$maxtime, 4.00) 
  expect_equal(procB$maxtime, 3.00) 
  expect_equal(as.numeric(procA$param[1:3]), as.numeric(ratesA))
})
# TODO: test that proceeded simulation is really compatible with previous object
