library(facilitation)
context("Community")

test_that("Basic community usage", {
  rates <- matrix(c(1.01,0,2.21),nrow=1)
  results <- community(maxtime=2.45,numstages=1,parameters=rates,init=11, height=189.9, width=91.1)
  # The resulting object should be a names list, with a predictable structure
  expect_equal(class(results), "list")
  expect_equal(names(results), c("data","num.pop","num.total","num.stages","maxtime","interactions","param","init","height","width","boundary","dispKernel"))
  expect_equal(names(results$data), c("sp","id","x","y","begintime","endtime"))
  # Some general expectations from this simulation
  expect(all(results$data$sp ==1), "Wrong sp labels")
  expect(all(results$data$id >=0), "Wrong id labels")
  # See issue #24
  expect(all(results$data$x >= 0 & results$data$x <= results$width), "Individuals outside arena")
  expect(all(results$data$y >= 0 & results$data$y < results$height), "Individuals outside arena")
  expect(nrow(results$data) > 30, "Too few data lines")
  # Passed arguments should be returned
  expect_equal(results$width, 91.1)
  expect_equal(results$height, 189.9)
  expect_equal(results$num.stages, 1) # Vector with stage structure
  expect_equal(results$num.total, 1) # Sum of num.stages
  expect_equal(results$num.pop, 1) # Length of num.stages
  expect_equal(results$maxtime, 2.45) 
  expect_equal(as.numeric(results$param[1:3]), as.numeric(rates)) #kinda wobbly?
  expect_equal(results$init, 11)
  # See issue #25
  results2 <- community(maxtime=2.45,numstages=1,parameters=rates/10,init=11, height=189.9, width=91.1)
  expect(any(results2$data$id ==0), "Not reseting id labels") 
})

test_that("Community should not allow incorrect parameters", {
  # Community function should not allow incorrect specifications
  expect_error(community(maxtime=2,numstages=1,parameters=rates,init=0)) #zero individuals
  expect_error(community(maxtime=2,numstages=2,parameters=matrix(c(0,0,0,1,0,0), nrow=2),init=10)) # positive growth on last stage
  expect_error(community(maxtime=2,numstages=2,parameters=rates,init=10)) # incompatible rate / numstages
  expect_error(community(maxtime=2,numstages=2,parameters=matrix(c(1,0,2,0,1,1), nrow=2),init=c(-5,10))) # negative population
  expect_error(community(maxtime=2,numstages=2,parameters=matrix(c(-1,0,-2,0,1,1), nrow=2),init=c(5,10))) # negative rates

})

# TODO: test multiple stages / populations. Interactions go on their own file
