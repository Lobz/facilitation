example <- function (x) {
  .Call(Cexample)
  print("Sample R function")
}

test_ <- function(inputfile) {
	.Call(r_test,inputfile)
	print("End testing function")
}
