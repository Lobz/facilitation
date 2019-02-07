#' Functions for matrix population model 
#' 
#' These functions produce the matrix population model matrices for a continuous time structured population model.
#' Function \code{mat.model} receives as an input the result of a simulation (from function \code{community}), or a
#' data.frame containing the model parameters
#' If there is more than one population,
#' returns a list of matrices, or one block-diagonal matrix created by the combination.
#' The \code{solution.matrix} function returns the solution to a linear ODE of the form P' = MP,
#' which is merely P(t) = exp(Mt)p0 where p0 is the initial condition.
#' The function \code{limiting.rate} returns the real dominant eigenvalue of a Matrix Population Model matrix. 
#' That is a real number that corresponds to the per-capita growth rate that a population
#' approaches as time passes, in a model with no interactions.
#' A structured population can grow at exactly this rate if the
#' distribution between stages corresponds exactly to the distribution of the dominant
#' eigenvector. The models that can be simulated by this package are of a class that always
#' has a real dominant eigenvector. Note that these are continuous-time models, in which r >
#' 0 means the population will grow, and r < 0 means it will decrease. This function doesn't
#' throw errors, instead it returns 'NA'.
#' @param data Either the result of a simulation, to extract the parameters from, or a
#' data.frame containing the parameters.
#' @param ns an array of numbers of stages. Use when \code{data} is a data.frame and the is
#' more than one population.
#' @param combine.matrices Logical. Combine the matrices into a single, multi-population matrix?
#' @examples
#' # Generating a mat model from random parameters and exploring the solution matrix
#' mat <- mat.model(create.parameters(n=4))
#' solution.matrix(c(1,0,0,0),mat)
#' 
#' # Extracting the mat model from a simulation object and checking the limiting rate
#' data(malthusian)
#' mat <- mat.model(malthusian)
#' limiting.rate(mat)
#' 
#' # Working with more than one species
#' data(twospecies)
#' mat.model(twospecies,combine.matrices=TRUE)
#' @export
#' @importFrom Matrix bdiag
mat.model <- function(data, ns, combine.matrices=FALSE){
    if(class(data)=="data.frame"){
        rates<-data
        if(missing(ns)){
            n<-1
        }
        else {
            if (sum(ns) != nrow(data))
                stop("The number of stages in ns does not match the specified parameters")
            n <- length(ns)
        }
    }
    else {
        if(!missing(ns))
            warning("Parameter ns is ignored if 'data' is a simulation result")
        rates<-data$param
        n<-data$num.pop
        ns<-data$num.stages
    }

    if(n==1){
        ns<-nrow(rates)
        mat.model.base(ns,rates$D,rates$G,rates$R)
    }
    else{
        nstarts<-c(1,sapply(1:(n-1),function(i)sum(ns[1:i])+1))
        Ms <- lapply(1:n,function(i){
                            r<-rates[1:ns[i]+nstarts[i]-1,]
                            mat.model.base(ns[i],r$D,r$G,r$R)
                        }
                    )
        if(combine.matrices){ # It's more clear if the return object is always from the same class
            as.matrix(Matrix::bdiag(Ms))
        }
        else {
            Ms
        }
    }
}

#' @param p0 initial condition, as an array
#' @param times an array containing the times in which to calculate the solution
#' @export
#' @importFrom Matrix expm
#' @rdname mat.model
solution.matrix <- function(p0, mat, times = c(1:10)){
    if(length(p0) != ncol(mat)) 
        stop("The initial condition must have the same length as the number of stages")
    expm <- function(mat) as.matrix(Matrix::expm(mat))

    S <- matrix(nrow=nrow(mat),ncol=length(times))
    for(i in 1:length(times)){
        S[,i] <- expm(mat*times[i]) %*% p0
    }
    colnames(S) <- times
    t(S)
}

#' @param mat a square matrix
#' @export
#' @rdname mat.model
limiting.rate <- function(mat){tryCatch(max(Re(eigen(mat,symmetric=F)$values)),error=function(e) NA)}

# Internal use
# @param n The number of life stages. Default is 3.
# @param Ds An n-array with death rates for each stage.
# @param Gs An (n-1)-array with growth rates for each stage but the last.
# @param Rs Either a single reproduction rate for the oldest stage, or an n-array of reproduction rates for each stage.
# @import stats
mat.model.base  <- function(n=3,Ds,Gs,Rs){
    if(n==1){
        Rs-Ds
    }
    else{
        if(length(Rs)==1){Rs <- c(rep(0,n-1),Rs)}
        Gs[n] <- 0
        M <- diag(-Ds-Gs) + diag(Gs)[c(n,1:(n-1)),]
        M[1,] <- M[1,] + Rs
        M
    }
}
