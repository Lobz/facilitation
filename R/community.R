#' Runs a simulation with a structured population and a non-structured facilitator population
#'
#' All effects affect death rates. Effects are subtracted from death rates, meaning that positive
#' effects decrease death rates while negative ones increase death rates.
#' 
#' @param maxtime 	How long the simulation must run
#' @param N         Number of populations
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
#' malth <- community(2,c(3,2),d,g,r,dispersal=2,init=init)
#' times <- seq(0,2,by=0.1)
#' ab <- abundance_matrix(malth,times)
#' stackplot(ab[,1:3]) # species 1
#' stackplot(ab[,4:5]) # species 2
facilitation <- function(maxtime, n, D, G, R, dispersal, init, # the main parameters
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
    Gs <- unlist(sapply(G,function(i){c(i,0)}))
    Rs <- unlist(R)
	M <- t(matrix(c(
			Gs, 0, #Gs
			rep(0, n-1),R, #Rs
			Ds, #Ds
			radius, #Rads
			maxstresseffects, facilitatorS #effects
		), nrow = n+1))

	N <- matrix(interactions,nrow=n)
	N <- rbind(N,c(fac,0))
	N <- c(N,rep(0,n),facilitatorI)

    # generate init parameter
    restore=F
    if(class(init)=="data.frame"){
        # super trusting that the data.frame has the correct columns
        restore=T
        hist=init
        initial=c(1)
    }
    else {
        initial=init
        hist=data.frame()
        restore=F
    }

	# run simulation
	r <- simulation(maxtime,num_stages=n,parameters=c(M),dispersal=dispersal,interactions=N,
                    init=initial,history=hist,restore=restore,h=height,w=width,bcond=bound,dkernel=disp,maxpop=maxpop)


    # obs: the object returned by function simulation, defined in main.cpp, is a data.frame with
    # columns [sp, id, x, y, begintime, endtime]
    # the following adjustments are made on this side because of the limits of c++ data types
	r[r==-1]=NA
	r$sp <- factor(r$sp)
	
	# prepare output
	N <- matrix(N,nrow=n+1)
	rownames(N) <- 0:n
	colnames(N) <- 0:n

	list(data = r,n=n+1, maxtime=maxtime,
	     stages=n,Ds=Ds,Gs=Gs,R=R,radius=radius,dispersal=dispersal,interactions=N,interactions.vec=interactions,rates.matrix=M,
	     init=init,height=height,width=width,boundary=boundary,dispKernel=dispKernel)
}
#dt <- facilitation(times=times, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)

#' creates a matrix with abundances of each life stage/species over time
#' 
#' @param data	result of a simulation, created by \code{\link{facilitation}}
#' @param times	array of times at which the abundances will be calculated
#' @examples
#' malth <- facilitation(2,3,Ds=c(5,1.2,0.1),Gs=c(1,.5),R=10,dispersal=2,init=c(100,0,0,0))
#' times <- seq(0,2,by=0.1)
#' ab <- abundance_matrix(malth,times)
#' stackplot(ab[,1:3])
abundance_matrix <- function(data,times=seq(0,data$maxtime,length.ou=20)){
	if(max(times) > data$maxtime){ "Warning: array of times goes further than simulation maximum time" }
	n <- data$n
	subs <- lapply(times,function(t){subset(data$data,begintime <= t & (endtime >= t | is.na(endtime)),select=c(1,2))})
	abmatline <- function(x){
		l <- tapply(x$id,x$sp,length)
		# complete the rows that are missing
		if(length(l) == n){
			abl = l
		}
		else {
			abl <- rep(0,n)
			names(abl) <- 1:n
			for(i in 1:n){
				if(i %in% names(l)){
					c <- which(names(l)==i)
					abl[i] <- l[c]
				}
			}		
		}
		# if that didn't work because of NA's
		abl[is.na(abl)] <- 0

		abl
	}
	ab <- t(sapply(subs,abmatline))
	rownames(ab) <- times

	ab
}

#' proceed with a stopped simulation
#'
#' @param data result of a simulation, created by \code{\link{facilitation}}
#' @param time a number: for how long to extend the simulation
#'
#'
proceed <- function(data,time){
	facilitation(init=data$data,n=data$stages, maxtime=data$maxtime+time,
	     Ds=data$Ds,Gs=data$Gs,R=data$R,radius=data$radius,dispersal=data$dispersal,interactions=data$interactions.vec,
	     height=data$height,width=data$width,boundary=data$boundary,dispKernel=data$dispKernel)
}
