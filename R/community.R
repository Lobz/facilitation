#' community
#'
#' Runs a simulation with any number of structured populations, for a limited time.
#' 
#' @param maxtime 	How long the simulation must run
#' @param numstages Array of number of stages for each population
#' @param parameters 	Data.frame or matrix with one row for each stage. Columns:
#' D,G,R,radius(optional),maxstressefect (optional)
#' @param init		Either an array of initial numbers for each stage of each population, or a
#' data.frame with the history of a simulation
#' @param dispersal	Average distance for seed dispersal
#' @param interactionsD	Optional. A square matrix of effects of life stages over each other, where element
#' [i,j] is the effect of stage i over stage j. Positive values equal facilitation, negative
#' ones, competition. The interactions occur only if the affected individual is within the affecting
#' individual's radius, and are additive. Affects death rates (is subtracted from D).
#' @param interactionsG	Same as above, but affecting growth rates (is added to G).
#' @param interactionsR	Same as above, but affecting reproduction rates (is added to R) .
#' @param height	Arena height
#' @param width		Arena width
#' @param boundary	Type of boundary condition. Options are "reflexive", "absortive" and
#' "periodic". Default is reflexive.
#' @param dispKernel	Type of dispersion kernel. Options are "exponential" and "random", in which
#' seeds are dispersed randomly regardless of parent position (note: "random" option ignores
#' dispersal parameter)
#' @param maxpop	If the simulation reaches this many individuals total, it will stop. Default
#' is 30000.
#' @examples
#' init <- list(c(100,0,0),c(100,0))
#' ###               D G R  D G R  ...
#' param <- matrix(c(2,1,0, 1,1,0, .5,0,6, 1,1,0, .5,0,2), byrow=TRUE, nrow=5) 
#' malth <- community(3,c(3,2),param,dispersal=2,init=init)
#' times <- seq(0,3,by=0.1)
#' ab <- abundance.matrix(malth,times)
#' stackplot(ab[,1:3]) # species 1
#' stackplot(ab[,4:5]) # species 2
#' @export
#' @useDynLib facilitation
#' @import Rcpp
community <- function(maxtime, numstages, parameters, dispersal, init, # the main parameters
                         interactionsD, interactionsG, interactionsR, # interactions
                         height=100, width=100, boundary=c("reflexive","absortive","periodic"), # arena properties
                         dispKernel=c("exponential","random"), # type of dispersal
                         maxpop=30000){

	# generate parameters for simulation
	dispKernel <- match.arg(dispKernel)
	disp <- switch(dispKernel, random=0,exponential=1)
	boundary <- match.arg(boundary)
	bound <- switch(boundary,reflexive=1,absortive=0,periodic=2)

    ntot <- sum(numstages)
    npop <- length(numstages)

	if(missing(interactionsD)){
        interactionsD = matrix(rep(0,ntot*ntot),ntot)
    }

	if(missing(interactionsG)){
        interactionsG = matrix(rep(0,ntot*ntot),ntot)
    }

	if(missing(interactionsR)){
        interactionsR = matrix(rep(0,ntot*ntot),ntot)
    }
    inter <- list(D=matrix(interactionsD,ntot),G=matrix(interactionsG,ntot),R=matrix(interactionsR,ntot))

    M <- as.matrix(parameters)
    if(nrow(M) != ntot){
        stop("Total number of stages differs from number of rows in parameter matrix")
    }
    if(ncol(M)==4){ # assume maxstresseffect is missing
        M <- cbind(M,rep(0,ntot))
    }
    else if(ncol(M)==3){ # assume radius and maxstress effect are missing
        M <- cbind(M,rep(1,ntot))
        M <- cbind(M,rep(0,ntot))
    }
    else if(ncol(M)!=5){
        stop("Parameter matrix must have 3-5 columns")
    }

    # check if growth rates for last stages are 0
    idold<-0
    for(i in 1:npop){
        idold <- idold+numstages[i]
        if(M[idold,2] != 0){ # eldest stage with a growth rate
            stop("Invalid input: positive growth rate for last stage of population")
        }
    }

    # generate init parameter
    restore=F
    if(class(init)=="data.frame"){
        # super trusting that the data.frame has the correct columns
        # columns [sp, id, x, y, begintime, endtime]
        restore=T
        hist=init
        initial=c(1)
    }
    else {
        initial=unlist(init)
        if(length(initial)!=ntot){
            stop("Invalid input: length of initial population array is not the same as number of stages")
        }
        hist=data.frame()
        restore=F
    }

	# run simulation
	r <- simulation(maxtime,num_pops=npop,num_stages=numstages,parameters=c(t(M)),dispersal=dispersal,
                    interactionsD=interactionsD,interactionsG=interactionsG,interactionsR=interactionsR,
                    init=initial,history=hist,restore=restore,h=height,w=width,bcond=bound,dkernel=disp,maxpop=maxpop)


    # obs: the object returned by function simulation, defined in main.cpp, is a data.frame with
    # columns [sp, id, x, y, begintime, endtime]
    # the following adjustments are made on this side because of the limits of c++ data types
	r[r==-1]=NA
	r$sp <- factor(r$sp)
	
	# prepare output
    rownames(M) <- 1:ntot
    colnames(M) <- c("D","G","R","radius","maxstresseffect")

	list(data = r,num.pop = npop, num.total = ntot, num.stages = numstages, maxtime=maxtime,
	     dispersal=dispersal,interactions=inter,param=data.frame(M),
	     init=init,height=height,width=width,boundary=boundary,dispKernel=dispKernel)
}

#' proceed
#'
#' Proceed with a stopped simulation.
#'
#' @param data result of a simulation, created by \code{\link{community}}
#' @param time a number: for how long to extend the simulation
#' @export
proceed <- function(data,time){
    d<-data$data
    current<-subset(d,is.na(d$endtime))
    past.hist<-subset(d,!is.na(d$endtime))

    c <- community(init=current,numstages=data$num.stages, maxtime=data$maxtime+time,
                   parameters=data$param,dispersal=data$dispersal,
                   interactionsD=data$interactions$D, 
                   interactionsG=data$interactions$G, 
                   interactionsR=data$interactions$R, 
                   height=data$height,width=data$width,
                   boundary=data$boundary,dispKernel=data$dispKernel)

    r<-c$data
    b<-rbind(r,past.hist)
    c$data<-b
    c
}

#' restart
#'
#' Turn back time and restart a simulation from time t
#'
#' @param data result of a simulation, created by \code{\link{community}}
#' @param time a number: for how long to extend the simulation
#' @param start a number: an instant in time to begin from
#'
#'
#' @export
restart <- function(data,time,start=0){
    d<-data$data
    if(start>0){
        d<-subset(d,d$begintime<=start & (d$endtime > start | is.na(d$endtime)))
        d$begintime<-0
    }
    else{
        d<-subset(d,d$begintime==0)
    }
    d$endtime<-NA

    community(init=d,numstages=data$num.stages, maxtime=time,
              parameters=data$param,dispersal=data$dispersal,
              interactionsD=data$interactions$D, 
              interactionsG=data$interactions$G, 
              interactionsR=data$interactions$R, 
              height=data$height,width=data$width,
              boundary=data$boundary,dispKernel=data$dispKernel)

}

