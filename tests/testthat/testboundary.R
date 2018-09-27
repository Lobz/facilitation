context("Boundary conditions")
#plotsnapshot(results)

test_that("Working boundary conditions", {
  # Generates a "blob" of individuals at the limit of the plot to test bound conditions
  set.seed(42)
  rates <- matrix(c(0,0,1),nrow=1)
  base <- community(maxtime=3,numstages=1,parameters=rates,init=20, width=5, height=5, boundary="reflexive")
  base$width = 50
  base$height = 50

  # Runs different simulations with the three boundary conditions
  refl = proceed(base, 1)
  Nrefl = abundance.matrix(refl)[50]
  abso = base
  abso$boundary = "absorptive"
  abso = proceed(abso, 1)
  Nabso = abundance.matrix(abso)[50]
  peri = base
  peri$boundary = "periodic"
  peri = proceed(peri, 2)
  expect_gt(Nrefl, Nabso) # absorptive must "kill" some individuals

  # No individuals should die on refl, peri
  expect(!any(is.na(refl$data[3:4])), "NA values in refl BC")
  expect(any(is.na(abso$data[3:4])), "No NA values in abso BC")
  expect(!any(is.na(peri$data[3:4])), "NA values in peri BC")

  expect(!any(refl$data$x > 25, na.rm=T), "Too high position in refl BC")
  expect(!any(refl$data$y > 25, na.rm=T), "Too high position in refl BC")
  expect(!any(abso$data$x > 25, na.rm=T), "Too high position in abso BC")
  expect(!any(abso$data$y > 25, na.rm=T), "Too high position in abso BC")

  expect(!any(refl$data$x < 0, na.rm=T), "Point outside bounds in refl BC")
  expect(!any(refl$data$y < 0, na.rm=T), "Point outside bounds in refl BC")
  expect(!any(abso$data$x < 0, na.rm=T), "Point outside bounds in abso BC")
  expect(!any(abso$data$y < 0, na.rm=T), "Point outside bounds in abso BC")

  expect(!any(peri$data$x > 50, na.rm=T), "Point outside bounds in peri BC")
  expect(!any(peri$data$y > 50, na.rm=T), "Point outside bounds in peri BC")
  expect(!any(peri$data$x < 0, na.rm=T), "Point outside bounds in peri BC")
  expect(!any(peri$data$y < 0, na.rm=T), "Point outside bounds in peri BC")
  expect(any(peri$data$x > 25, na.rm=T), "Peri BC not producing high points")
  expect(any(peri$data$y > 25, na.rm=T), "Peri BC not producing high points")
})

test_that("Working boundary conditions for high X/Y", {
  # Generates a "blob" of individuals at the UPPER limit of the plot to test bound conditions
  set.seed(42)
  rates <- matrix(c(0,0,1),nrow=1)
  baseh <- community(maxtime=3,numstages=1,parameters=rates,init=20, width=5, height=5, boundary="reflexive")
  baseh$width = 50
  baseh$height = 50
  baseh$data$x = baseh$data$x + 45
  baseh$data$y = baseh$data$y + 45
  refl = proceed(baseh, 1)
  Nrefl = abundance.matrix(refl)[50]
  abso = baseh
  abso$boundary = "absorptive"
  abso = proceed(abso, 1)
  Nabso = abundance.matrix(abso)[50]
  peri = baseh
  peri$boundary = "periodic"
  peri = proceed(peri, 2)
  expect_gt(Nrefl, Nabso) # absorptive must "kill" some individuals

  expect(!any(is.na(refl$data[3:4])), "NA values in refl BC")
  expect(any(is.na(abso$data[3:4])), "No NA values in abso BC")
  expect(!any(is.na(peri$data[3:4])), "NA values in peri BC")

  expect(!any(refl$data$x < 25, na.rm=T), "Too low position in refl BC")
  expect(!any(refl$data$y < 25, na.rm=T), "Too low position in refl BC")
  expect(!any(abso$data$x < 25, na.rm=T), "Too low position in abso BC")
  expect(!any(abso$data$y < 25, na.rm=T), "Too low position in abso BC")

  expect(!any(refl$data$x > 50, na.rm=T), "Point outside bounds in refl BC")
  expect(!any(refl$data$y > 50, na.rm=T), "Point outside bounds in refl BC")
  expect(!any(abso$data$x > 50, na.rm=T), "Point outside bounds in abso BC")
  expect(!any(abso$data$y > 50, na.rm=T), "Point outside bounds in abso BC")

  expect(!any(peri$data$x > 50, na.rm=T), "Point outside bounds in peri BC")
  expect(!any(peri$data$y > 50, na.rm=T), "Point outside bounds in peri BC")
  expect(!any(peri$data$x > 50, na.rm=T), "Point outside bounds in peri BC")
  expect(!any(peri$data$y > 50, na.rm=T), "Point outside bounds in peri BC")
  expect(any(peri$data$x < 25, na.rm=T), "Peri BC not producing low points")
  expect(any(peri$data$y < 25, na.rm=T), "Peri BC not producing low points")

})

test_that("No dead zones (#18)", {
  # Generates a "blob" of individuals at the CENTER of the plot to test bound conditions
  set.seed(42)
  param <- create.parameters(D=c(2,0,0), G=c(1,0.2), R=1) # create the parameter object
  effects <- c(0,0,0, 0,-1,0, 0,0,-3)
  base <- community(20,3,param,c(10,10,10),interactionsD=effects,height=1,width=1)
  base$width = 20
  base$height = 20
  base$data$x = base$data$x + 14.5
  base$data$y = base$data$y + 14.5

  refl = proceed(base, 200)
  abso = base
  abso$boundary = "absorptive"
  abso = proceed(abso, 200)
  peri = base
  peri$boundary = "periodic"
  peri = proceed(peri, 200)

  expect(any(refl$data$x > 19, na.rm=T), "Dead zones in refl BC")
  expect(any(refl$data$y > 19, na.rm=T), "Dead zones in refl BC")
  expect(any(refl$data$x < 1, na.rm=T), "Dead zones in refl BC")
  expect(any(refl$data$y < 1, na.rm=T), "Dead zones in refl BC")
  expect(any(abso$data$x > 19, na.rm=T), "Dead zones in abso BC")
  expect(any(abso$data$y > 19, na.rm=T), "Dead zones in abso BC")
  expect(any(abso$data$x < 1, na.rm=T), "Dead zones in abso BC")
  expect(any(abso$data$y < 1, na.rm=T), "Dead zones in abso BC")
  expect(any(refl$data$x > 19, na.rm=T), "Dead zones in refl BC")
  expect(any(refl$data$y > 19, na.rm=T), "Dead zones in refl BC")
  expect(any(refl$data$x < 1, na.rm=T), "Dead zones in refl BC")
  expect(any(refl$data$y < 1, na.rm=T), "Dead zones in refl BC")
})
