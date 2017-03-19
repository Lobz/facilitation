library(parallel)
load_all()

	run1fbr <- function(times){c(length(times),system.time(facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)))}
	run2 <- function(times){facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)}
	run1 <- function(times){facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, init=initialpop, rad=radius, h=h, w=w)}

timedruns <- function(maxtime,numtimes=rep(1:100,4)){

	genseq <- function(n){seq(0,maxtime,length.out=n)}
	lt <- lapply(numtimes,genseq)

	tr <- t(data.frame(mclapply(lt,run1fbr)))
	rownames(tr) <- numtimes

	tr
}

wrapper <- function(maxt){
	facByRates(maxt, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=disp, R=reproductionrate, 
	   interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)
}
ts <- function(maxt){ c(maxt,system.time(wrapper(maxt))) }
maxtimedruns <- function(maxtimes=rep(5:10,4)){

	tr <- t(data.frame(mclapply(maxtimes,ts)))
	rownames(tr) <- maxtimes

	tr
}
