context("Mat Model")
set.seed(42)

test_that("Mat model usage", {
  param = create.parameters(D = c(1,1,1,1), G = c(4,4,1), R = c(0,0,2,7))
  results = community(1, numstages=4, parameters=param, init=c(20,20,15,15))
  mat <- abundance.matrix(results)

  pmodel = mat.model(param)
  rmodel = mat.model(results)
  # Structure of the resulting matrix
  expect_equal(class(pmodel), "matrix")
  expect_equal(ncol(pmodel), 4)
  expect_equal(nrow(pmodel), 4)
  expect_identical(pmodel, rmodel)
  expect_identical(pmodel, matrix(c(-5,4,0,0,0,-5,4,0,2,0,-2,1,7,0,0,-1), byrow=FALSE, ncol=4))

  # With two populations
  model = mat.model(param, ns=c(2,2), combine.matrices = FALSE)
  expect_equal(class(model), "list")
  expect_equal(class(model[[1]]), "matrix")
  expect_equal(nrow(model[[1]]), 2)
  expect_equal(ncol(model[[1]]), 2)
  expect_equal(model[[1]], matrix(c(-5,4,0,-1), byrow=FALSE, ncol=2))
  model = mat.model(param, ns=c(2,2), combine.matrices = TRUE)
  expect_equal(class(model), "matrix")
  expect_equal(ncol(model), 4)
  expect_equal(nrow(model), 4)
  dimnames(model) <- NULL # Clearing dimnames to have a comparable object...
  expect_identical(model, matrix(c(-5,4,0,0,0,-1,0,0,0,0,0,1,0,0,7,-1), byrow=FALSE, ncol=4))
  # Should be errors
  expect_error(mat.model(param, ns=c(1,1,1,1,1)))
  expect_error(mat.model(param, ns=c(1,1)))

  # A very small matrix...
  param = create.parameters(D = 1, G = 0, R = 1.2)
  expect_equal(mat.model(param), 0.2)
})

test_that("Solution matrix / lim rate", {
  param = create.parameters(D = c(1,1,1,1), G = c(4,4,1), R = c(0,0,2,7))
  model = mat.model(param)

  sol = solution.matrix(c(10,10,5,5), model, c(0, 0.5, 1))
  expect_equal(class(sol), "matrix")
  expect_equal(nrow(sol), 3)
  expect_equal(ncol(sol), 4)
  expect_equal(rownames(sol), c("0", "0.5", "1"))
  expect_identical(sol[1,], c(10,10,5,5))
  expect_equal(round(sum(sol[3,])), 63)

  expect_error(solution.matrix(c(10,10,5), model, c(0, 0.5, 1)))

  expect_identical(limiting.rate(0.7), 0.7)
  expect_identical(round(limiting.rate(model),2), 0.8)
  expect_identical(limiting.rate(list(1)), NA) # Never throws errors
})
