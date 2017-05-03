#' Runs a simulation with a structured population and a non-structured facilitator population
#'
#' All effects affect death rates. Effects are subtracted from death rates, meaning that positive
#' effects decrease death rates while negative ones increase death rates.
#' 
#' @param maxtime 	How long the simulation must run
#' @param numstages Array of number of stages for each population
#' @param parameters 	Matrix with one row for each stage. Columns:
#' D,G,R,radius(optional),maxstressefect (optional)
#' @param init		Either an array of initial numbers for each stage of each population, or a
#' data.frame with the history of a simulation
#' @param dispersal	Average distance for seed dispersal
#' @param maxstresseffects		Optional (use for a stress gradient). Array of values for the slope
#' of increase of environmental effect on each stage
#' @param interactions	Optional. An array of effects of life stages over each other, where element
#' [i+n*j] means the effect of stage i over stage j. Positive values equal facilitation, negative ones, competition.
#' @param height	Arena height
#' @param width		Arena width
#' @param boundary	Type of boundary condition. Options are "reflexive", "absortive" and
#' "periodic". Default os reflexive.
#' @param dispKernel	Type of dispersion kernel. Options are "exponential" and "random", in which
#' seeds are dispersed randomly regarless of parent position (note: "random" option ignores
#' dispersal parameter)
#' @param maxpop	If the simulation reaches this many individuals total, it will stop. Default
#' is 30000.
#' @examples
#' init <- list(c(100,0,0),c(100,0))
#' malth <- community(2,c(3,2),d,g,rep,dispersal=2,init=init)
#' times <- seq(0,2,by=0.1)
#' ab <- abundance_matrix(malth,times)
#' stackplot(ab[,1:3]) # species 1
#' stackplot(ab[,4:5]) # species 2
community <- function(maxtime, numstages, parameters, dispersal, init, # the main parameters
                         interactions, # interactions
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

	if(missing(interactions)){
        interactions = matrix(rep(0,ntot*ntot),ntot)
    }

    M <- parameters
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
        hist=data.frame()
        restore=F
    }

	# run simulation
	r <- simulation(maxtime,num_pops=npop,num_stages=numstages,parameters=c(t(M)),dispersal=dispersal,interactions=interactions,
                    init=initial,history=hist,restore=restore,h=height,w=width,bcond=bound,dkernel=disp,maxpop=maxpop)


    # obs: the object returned by function simulation, defined in main.cpp, is a data.frame with
    # columns [sp, id, x, y, begintime, endtime]
    # the following adjustments are made on this side because of the limits of c++ data types
	r[r==-1]=NA
	r$sp <- factor(r$sp)
	
	# prepare output
	rownames(interactions) <- 1:ntot
	colnames(interactions) <- 1:ntot
    rownames(M) <- 1:ntot
    colnames(M) <- c("D","G","R","radius","maxstresseffect")

	list(data = r,num.pop = npop, num.total = ntot, num.stages = numstages, maxtime=maxtime,
	     dispersal=dispersal,interactions=interactions,rates.matrix=M,radius=M[,4],
	     init=init,height=height,width=width,boundary=boundary,dispKernel=dispKernel)
}

#' proceed with a stopped simulation
#'
#' @param data result of a simulation, created by \code{\link{facilitation}}
#' @param time a number: for how long to extend the simulation
#'
#'
proceed <- function(data,time){
	community(init=data$data,numstages=data$num.stages, maxtime=data$maxtime+time,
	     parameters=data$rates.matrix,dispersal=data$dispersal,interactions=data$interactions,
	     height=data$height,width=data$width,boundary=data$boundary,dispKernel=data$dispKernel)
}

