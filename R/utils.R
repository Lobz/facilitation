snapshotdataframe <- function(x,times) {
	lapply(times,function(t){subset(x,begintime <= t & (endtime >= t | is.na(endtime)))}) -> res
	t <- times[1]
	snap <- cbind(t,res[[1]])
	if(length(times)>1){
		for(i in 2:length(times)){
			t <- times[i]
			snap <- rbind(snap,cbind(t,res[[i]]))
		}
	}

	snap
}

#' Runs a simulation with a structured population and a non-structured facilitator population
#'
#' All effects affect death rates. Effects are subtracted from death rates, meaning that positive
#' effects decrease death rates while negative ones increase death rates.
#' 
#' @param maxtime 	How long the simulation must run
#' @param n 		Number of stages in the structured population
#' @param Ds		An array of death rates for the structured population, of length \code{n}
#' @param Gs		An array of growth rates for the structured population, of length \code{n-1}
#' @param fac		Optional. An array of effects of the facilitator over each stage of the beneficiary
#' species, of length \code{n-1}. Positive values equal facilitation, negative ones, competition.
#' @param R		Rate of seed production by adult of the structured population
#' @param init		An array of initial numbers for each stage of the structured population, and
#' the facilitator population. Length n+1.
#' @param dispersal	Average distance for seed dispersal
#' @param rad		Optional (use if there are any interactions). Array of interaction radiuses. Length n+1.
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
#' @param facilitatorD	Facilitator death rate
#' @param facilitatorR	Facilitator reproduction rate
#' @param facilitatorI	Facilitator intraspecific effect
#' @examples
#' malthusian <- facByRates(maxtime=2,n=3,Ds=c(5,1.2,0.1),Gs=c(1,.5),R=10,dispersal=2,init=c(100,0,0,0),rad=c(0,1,2,0))
#' times <- seq(0,2,by=0.1)
#' ab <- abundance_matrix(malthusian,times)
#' stackplot(ab[,1:3])
facByRates <- function(maxtime, n, Ds, Gs, R, init, dispersal, rad=rep(2,n+1), interactions=rep(0,n*n), fac=rep(0,n-1), height=100, width=100, boundary="reflexive", facilitatorD=0,facilitatorR=0,facilitatorI=0, dispKernel="exponential", maxpop=30000){

	# generate parameters for test_parameters
	if(length(rad)==1) rad <- c(rep(0,n),rad)
	M <- t(matrix(c(Gs, 0, 0, rep(0, n-1),R,facilitatorR, Ds,facilitatorD, rad), nrow = n+1))
	N <- matrix(interactions,nrow=n)
	N <- rbind(N,c(fac,0))
	N <- c(N,rep(0,n),facilitatorI)

	if(dispKernel=="random") disp=0
	else if(dispKernel=="exponential") disp=1
	else {
		"dispKernel not understood"
		return(NULL)
	}
	
	if(boundary=="reflexive") boundary=1
	else if(boundary=="absortive") boundary=0
	else if(boundary=="periodic") boundary=2
	else {
		"boundary not understood"
		return(NULL)
	}
	

	# run simultation
	r <- test_parameter(maxtime,num_stages=n,parameters=c(M),dispersal=dispersal,interactions=N,init=init,h=height,w=width,bcond=boundary,dkernel=disp,maxpop=maxpop)
	
	# prepare output
	N <- matrix(N,nrow=n+1)
	rownames(N) <- 0:n
	colnames(N) <- 0:n

	r[r==-1]=NA
	r$sp <- factor(r$sp)


	list(data = r,n=n+1, maxtime=maxtime,
	     stages=n,D=Ds,G=Gs,R=R,radius=rad,dispersal=dispersal,interactions=N,init=init,h=height,w=width,bcond=boundary,dkernel=dispKernel)
}
#dt <- facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)

#' creates a matrix with abundances of each life stage/species over time
#' 
#' @param data	result of a simulation, created by \code{\link{facByRates}}
#' @param times	array of times at which the abundances will be calculated
#' @examples
#' malthusian <- facByRates(maxtime=2,n=3,Ds=c(5,1.2,0.1),Gs=c(1,.5),R=10,dispersal=2,init=c(100,0,0,0),rad=c(0,1,2,0))
#' times <- seq(0,2,by=0.1)
#' ab <- abundance_matrix(malthusian,times)
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
			names(abl) <- 0:(n-1)
			for(i in 0:(n-1)){
				if(i %in% names(l)){
					c <- which(names(l)==i)
					abl[i+1] <- l[c]
				}
			}		
		}
		abl
	}
	ab <- t(sapply(subs,abmatline))
	rownames(ab) <- times

	ab
}
