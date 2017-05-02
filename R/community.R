#' Runs a simulation with a structured population and a non-structured facilitator population
#'
#' All effects affect death rates. Effects are subtracted from death rates, meaning that positive
#' effects decrease death rates while negative ones increase death rates.
#' 
#' @param maxtime 	How long the simulation must run
#' @param n 		Array of number of stages for each population
#' @param D		List of lenght N containing arrays of death rates for each stage of each population
#' @param G		List of lenght N containing arrays of growth rates for each stage of each population
#' @param R		List of lenght N containing arrays of seed production rates for each stage of each population
#' @param init		List of lenght N containing arrays of initial numbers for each stage of the
#' structured populations
#' @param dispersal	List of lenght N containing average distances for seed dispersal for each
#' population
#' @param maxstresseffects		Optional (use for a stress gradient). Array of values for
#' how much the environmental stress can increse death rate at maximum stress. Length n+1. Stress
#' gradient is linear, being miminum a x=0 (left) and maximum at x=width (right).
#' @param radius		Optional (use if there are any interactions). Array of interaction radiuses. Length n+1.
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
#' d <- list(c(5,2,.1),c(2,1))
#' g <- list(c(5,2),c(1))
#' rep <- list(c(0,1,10),c(0,8))
#' init <- list(c(100,0,0),c(100,0))
#' malth <- community(2,c(3,2),d,g,rep,dispersal=2,init=init)
#' times <- seq(0,2,by=0.1)
#' ab <- abundance_matrix(malth,times)
#' stackplot(ab[,1:3]) # species 1
#' stackplot(ab[,4:5]) # species 2
community <- function(maxtime, n, D, G, R, dispersal, init, # the main parameters
                         maxstresseffects = rep(0,sum(n)), radius=rep(2,sum(n)), # stress gradient effects
                         interactions=rep(0,sum(n)*sum(n)), # interactions
                         height=100, width=100, boundary=c("reflexive","absortive","periodic"), # arena properties
                         dispKernel=c("exponential","random"), # type of dispersal
                         maxpop=30000){

	# generate parameters for simulation
	dispKernel <- match.arg(dispKernel)
	disp <- switch(dispKernel, random=0,exponential=1)
	boundary <- match.arg(boundary)
	bound <- switch(boundary,reflexive=1,absortive=0,periodic=2)

    ntot <- sum(n)
	if(length(radius)==1) radius <- rep(radius,ntot) # if only one radius specified, everybody has that radius

    Ds <- unlist(D)
    if(length(G)>0){
        Gs <- unlist(sapply(G,function(i){c(i,0)}))
    }
    else{
        G <- 0
    }
    Rs <- unlist(R)
	M <- t(matrix(c(
            Ds, Gs, Rs,
			unlist(radius), #Rads
			unlist(maxstresseffects) #effects
		), nrow = ntot))

	N <- matrix(interactions,nrow=ntot)

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
	r <- simulation(maxtime,num_pops=length(n),num_stages=n,parameters=c(M),dispersal=dispersal,interactions=N,
                    init=initial,history=hist,restore=restore,h=height,w=width,bcond=bound,dkernel=disp,maxpop=maxpop)


    # obs: the object returned by function simulation, defined in main.cpp, is a data.frame with
    # columns [sp, id, x, y, begintime, endtime]
    # the following adjustments are made on this side because of the limits of c++ data types
	r[r==-1]=NA
	r$sp <- factor(r$sp)
	
	# prepare output
	N <- matrix(N,nrow=ntot)
	rownames(N) <- 1:ntot
	colnames(N) <- 1:ntot

	list(data = r,n=n+1, maxtime=maxtime,
	     stages=n,D=D,G=G,R=R,radius=radius,dispersal=dispersal,interactions=N,interactions.vec=interactions,rates.matrix=M,
	     init=init,height=height,width=width,boundary=boundary,dispKernel=dispKernel)
}
