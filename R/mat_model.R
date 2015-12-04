
#' mat_model 
#' 
#' The \code{mat_model} function produces the interaction matrix for a structured
#' population model where only the last life stage reproduces, to be applyed in a linear ODE
#' @param n The number of life stages. Default is 3.
#' @param Ds An n-array with death rates for each stage. Default is rexp(n,1).
#' @param Gs An (n-1)-array with growth rates for each stage but the last. Default is rexp(n-1,1)
#' @param R Reproduction rate. Default is rexp(1,1).
#' @examples
#'mat <- mat_model(5)
#'mat2 <- mat_model(3,c(1,2,3),c(10,10),100)
mat_model  <- function(n=3,Ds=rexp(n,1),Gs=rexp(n-1,1),R=rexp(1,1)){
	Gs[n] <- 0
	M <- diag(-Ds-Gs) + diag(Gs)[c(n,1:(n-1)),]
	M[1,n] <- R
	M
}

expm <- function(M) as.matrix(Matrix::expm(M))

#' solution.matrix 
#' 
#' The \code{solution.matrix} function returns the solution to a linear ODE of the form P' = MP,
#' which is merely P(t) = exp(Mt)p0 where p0 is the initial condition
#' @param p0 initial condition, as an array
#' @param M a square matrix with as many rows as P0
#' @param times an array containing the times in which to calculate the solution
solution.matrix <- function(p0, M, times = c(1:10)){
	S <- matrix(nrow=nrow(M),ncol=length(times))
	for(i in 1:length(times)){
		    S[,i] <- expm(M*times[i]) %*% p0
	}
	colnames(S) <- times
	t(S)
}
	
#> mat_model(3,c(1,2,3),c(10,10),100)
#     [,1] [,2] [,3]
#[1,]  -11    0  100
#[2,]   10  -12    0
#[3,]    0   10   -3
#> mat <- model(5)
#           [,1]       [,2]       [,3]       [,4]       [,5]
#[1,] -1.5629490  0.0000000  0.0000000  0.0000000  0.3634946
#[2,]  0.3972985 -0.5617822  0.0000000  0.0000000  0.0000000
#[3,]  0.0000000  0.3668222 -2.8920797  0.0000000  0.0000000
#[4,]  0.0000000  0.0000000  0.5600529 -1.3567011  0.0000000
#[5,]  0.0000000  0.0000000  0.0000000  0.1860525 -0.6183549



	
