example <- function (x) {
  .Call(Cexample)
  print("Sample R function")
}

testin <- function() {
	.Call(test_from_cin)
	print("End testing function")
}
