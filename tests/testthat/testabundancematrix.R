library(facilitation)
context("Abundance matrix")
# whats the default number of rows in abundance.matrix?
DEFAULT_ROWS = 50

test_that("Basic abundance.matrix usage", {
  rates <- matrix(c(0,0,1),nrow=1)
  results <- community(maxtime=1.96,numstages=1,parameters=rates,init=20)
  mat <- abundance.matrix(results)
  # Structure of the abundance.matrix result
  expect_equal(class(mat), "matrix")
  expect_equal(ncol(mat), 1)
  expect_equal(nrow(mat), DEFAULT_ROWS)
  expect_equal(rownames(mat)[1], "0")
  expect_equal(rownames(mat)[DEFAULT_ROWS], "1.96")

  # With two stages...
  rates <- matrix(c(0,0,1,0,1,1),nrow=2)
  results <- community(maxtime=1.96,numstages=2,parameters=rates,init=c(10,10))
  mat <- abundance.matrix(results)
  expect_equal(ncol(mat), 2)

  # With two species
  rates <- matrix(c(0,0,0,1,0,0,1,1,1),nrow=3)
  results <- community(maxtime=1.96,numstages=c(2,1),parameters=rates,init=c(10,10,10))
  mat <- abundance.matrix(results)
  expect_equal(ncol(mat), 3)

  # If one species / stage goes extinct
  rates <- matrix(c(5,0,5,0,0,0,0,1,0),nrow=3)
  results <- community(maxtime=5,numstages=c(1,2),parameters=rates,init=c(10,10,10))
  mat <- abundance.matrix(results)
  expect_equal(ncol(mat), 3)
  expect_equal(mat[DEFAULT_ROWS, 1], 0)
  expect_equal(mat[DEFAULT_ROWS, 3], 0)
})
