#' Main simulation function
#'
#' Runs a simulation with any number of structured populations, for a limited time.
#' See the vignette for a detailed explanation of each parameter and use cases.
#' 
#' @param maxtime 	How long the simulation must run
#' @param numstages Array of number of stages for each population
#' @param parameters 	Data.frame or matrix with one row for each stage. Columns:
#' D, G, R, dispersal distance, radius (optional), maxstressefect (optional). See \code{\link{create.parameters}}
#' @param init		Either an array of initial numbers for each stage of each population, or a
#' data.frame with the history of a simulation
#' @param interactionsD	Optional. A square matrix of effects of life stages over each other, where element
#' [i,j] is the effect of stage i over stage j. Positive values equal facilitation, negative
#' ones, competition. The interactions occur only if the affected individual is within the affecting
#' individual's radius, and are additive. Affects death rates (is subtracted from D).
#' @param interactionsG	Same as above, but affecting growth rates (is added to G).
#' @param interactionsR	Same as above, but affecting reproduction rates (is added to R) .
#' @param height	Arena height
#' @param width		Arena width
#' @param boundary	Type of boundary condition. Options are "reflexive", "absorptive" and
#' "periodic". Default is reflexive.
#' @param dispKernel	Type of dispersion kernel. Options are "exponential" and "random", in which
#' seeds are dispersed randomly regardless of parent position (note: "random" option ignores
#' dispersal parameter)
#' @param starttime 	Use for proceeding simulations. Time when simulation begins.
#' @param maxpop	If the simulation reaches this many individuals total, it will stop. Default
#' is 30000.
#' @param maxid		Use for proceeding simulations. Maximum id used by the current simulation. Should probably never be set explicitly.
#' @examples
#' param <- data.frame(D=c(2,1,2,1),G=c(2,0,2,0),R=c(0,3,0,3),dispersal=c(0,2,0,20))
#' malth <- community(2,c(2,2),param,init=c(10,10,10,10))
#' ab <- abundance.matrix(malth)
#' stackplot(ab[,1:2]) # species 1
#' stackplot(ab[,3:4]) # species 2
#' @export
#' @useDynLib facilitation
#' @import Rcpp
community <- function(maxtime, numstages, parameters, init, # the main parameters
                         interactionsD, interactionsG, interactionsR, # interactions
                         height=100, width=100, boundary=c("reflexive","absorptive","periodic"), # arena properties
                         dispKernel=c("exponential","random"), # type of dispersal
                         starttime=0,
                         maxpop=30000,
			 maxid = 0){

	# generate parameters for simulation
	dispKernel <- match.arg(dispKernel)
	disp <- switch(dispKernel, random=0,exponential=1)
	boundary <- match.arg(boundary)
	bound <- switch(boundary,reflexive=1,absorptive=0,periodic=2)

    ntot <- sum(numstages)
    npop <- length(numstages)

    # main parameter
    M <- as.matrix(parameters)
    if (any(M < 0)) {
	    stop("Parameters should not be negative")
    }
    if(nrow(M) != ntot){
        stop("Total number of stages differs from number of rows in parameter matrix")
    }

    if(ncol(M) < 3 | ncol(M) > 7){
        stop("Parameter matrix must have 3-7 columns")
    }
    if(ncol(M)==3){ # assume dispersal is missing
        M <- cbind(M,rep(1,ntot))
    }
    if(ncol(M)==4){ # assume radius is missing
        M <- cbind(M,rep(1,ntot))
        if(!missing(interactionsD) | !missing(interactionsG) | !missing(interactionsR)){
            stop("To use interactions please set the values of dispersal and radius in parameters")
        }
    }
    if(ncol(M)==5){ # assume maxstresseffect is missing
        M <- cbind(M,rep(0,ntot))
    }
    if(ncol(M)==6){
        M <- cbind(M,rep(disp,ntot))
    }

    # check if growth rates for last stages are 0
    idold<-0
    for(i in 1:npop){
        idold <- idold+numstages[i]
        if(M[idold,2] != 0){ # eldest stage with a growth rate
            stop("Invalid input: positive growth rate for last stage of population")
        }
    }

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

    # generate init parameter
    restore=F
    if(class(init)=="data.frame"){
        # super trusting that the data.frame has the correct columns
        # columns [sp, id, x, y, begintime, endtime]
        restore=T
        hist=init
        initial=c(1)
        if(nrow(hist)==0){
            stop("Attempting to create simulation with zero individuals")
        }
    }
    else {
        initial=unlist(init)
        if(length(initial)!=ntot){
            stop("Invalid input: length of initial population array is not the same as number of stages")
        }
        if(any(initial < 0) | sum(initial) ==0){
            stop("Invalid input: attempting to create simulation with zero or negative number of individuals")
        }
        hist=data.frame()
        restore=F
    }
    if (!is.numeric(maxid) | length(maxid) > 1 | maxid < 0 | (!restore & maxid != 0)) {
	    stop("Invalid value for maxid parameter")
    }

	# run simulation
	r <- simulation(maxtime,num_pops=npop,num_stages=numstages,parameters=c(t(M)),
                    interactionsD=interactionsD,interactionsG=interactionsG,interactionsR=interactionsR,
                    init=initial,history=hist,restore=restore,h=height,w=width,bcond=bound,
                    starttime=starttime,maxpop=maxpop, maxid=maxid)


    # obs: the object returned by function simulation, defined in main.cpp, is a data.frame with
    # columns [sp, id, x, y, begintime, endtime]
    # the following adjustments are made on this side because of the limits of c++ data types
	r[r==-1]=NA
	
	# prepare output
    rownames(M) <- 1:ntot
    colnames(M) <- c("D","G","R","dispersal","radius","maxstresseffect","dkernel")

	list(data = r,num.pop = npop, num.total = ntot, num.stages = numstages, maxtime=maxtime,
	     interactions=inter,param=data.frame(M),
	     init=init,height=height,width=width,boundary=boundary,dispKernel=dispKernel)
}

#' Proceeding / restarting a simulation
#'
#' The function \code{proceed} proceeds with a stopped simulation. The function \code{restart} 
#' turns back time and restarts a simulation from time t.
#'
#' @param data result of a simulation, created by \code{\link{community}}
#' @param time numeric: for how long to extend the simulation
#' @export
proceed <- function(data,time){
    d<-data$data
    last.event.time<-max(c(d$endtime,d$begintime),na.rm=T)
    maxid = max(d$id)

    current<-subset(d,is.na(d$endtime))
    past.hist<-subset(d,!is.na(d$endtime))

    c <- community(init=current,numstages=data$num.stages, maxtime=data$maxtime+time,
                   parameters=data$param,
                   interactionsD=data$interactions$D, 
                   interactionsG=data$interactions$G, 
                   interactionsR=data$interactions$R, 
                   height=data$height,width=data$width,
                   boundary=data$boundary,dispKernel=data$dispKernel,
                   starttime=last.event.time, maxid = maxid)

    r<-c$data
    b<-rbind(r,past.hist)
    c$data<-b
    c
}

#' @param start numeric: an instant in time to begin from
#' @export
#' @rdname proceed
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
    maxid = max(d$id)

    community(init=d,numstages=data$num.stages, maxtime=time,
              parameters=data$param,
              interactionsD=data$interactions$D, 
              interactionsG=data$interactions$G, 
              interactionsR=data$interactions$R, 
              height=data$height,width=data$width,
              boundary=data$boundary,dispKernel=data$dispKernel,
	      maxid=maxid)
}

