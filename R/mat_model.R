
#' mat.model 
#' 
#' The \code{mat.model} function produces the interaction matrix for a structured
#' population model where only the last life stage reproduces, to be applyed in a linear ODE
#' @param n The number of life stages. Default is 3.
#' @param Ds An n-array with death rates for each stage.
#' @param Gs An (n-1)-array with growth rates for each stage but the last.
#' @param R A n-array of reproduction rates for each stage.
#' @examples
#'mat <- mat.model(5)
#'mat2 <- mat.model(3,c(1,2,3),c(10,10),100)
#' @export
#' @import stats
mat.model  <- function(n=3,Ds=runif(n,rep(.00001,n),c(rep(2,n-1),0.01)),Gs=runif(n-1,0.00001,2),R=rexp(n,1)){
	Gs[n] <- 0
	M <- diag(-Ds-Gs) + diag(Gs)[c(n,1:(n-1)),]
	M[1,] <- M[1,] + R
	M
}

#' Generate a matrix population model from the simulation parameters
#' @param data the result of a simulation
#' @export
simulation.to.mat.models <- function(data){
    rates<-data.frame(data$rates.matrix[,1:3])
    if(data$num.pop==1){
        mat.model(data$num.stages,rates$D,rates$G,rates$R)
    }
    else{
        n<-data$num.pop
        ns<-data$num.stages
        nstarts<-c(1,sapply(1:(n-1),function(i)sum(ns[1:i])+1))
        lapply(1:n,function(i){
                   r<-rates[1:ns[i]+nstarts[i]-1,]
                   mat.model(ns[i],r$D,r$G,r$R)
        })
    }
}

#' solution.matrix 
#' 
#' The \code{solution.matrix} function returns the solution to a linear ODE of the form P' = MP,
#' which is merely P(t) = exp(Mt)p0 where p0 is the initial condition
#' @param p0 initial condition, as an array
#' @param M a square matrix with as many rows as P0
#' @param times an array containing the times in which to calculate the solution
#' @export
#' @import Matrix
solution.matrix <- function(p0, M, times = c(1:10)){
    expm <- function(M) as.matrix(Matrix::expm(M))

    S <- matrix(nrow=nrow(M),ncol=length(times))
    for(i in 1:length(times)){
        S[,i] <- expm(M*times[i]) %*% p0
    }
    colnames(S) <- times
    t(S)
}

#' a function to calculate the dominant eigenvalue of a matrix
#' @param mat a matrix
#' @export
limiting.rate <- function(mat){tryCatch(max(Re(eigen(mat,s=F)$values)),error=function(e) NA)}
