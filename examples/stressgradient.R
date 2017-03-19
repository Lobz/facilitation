library(animation)
#1/(2+1)=1/3
#.2/(.2+1.4)=1/8
#s=1/24
#Rs=.25
#.2/(.2+.2)=1/2
#s=1/6
#Rs=1
numstages <- 3
deathrates <- c(2, 0.2, 0.5)  # death rates for seed, sapling and adult
growthrates <- c(1, 0.2)      # transition rates seed-->sapling and sapling-->adult
reproductionrate <- 6        # reproduction rate (only adult)
initialpop <- c(0,0,200,100)    # initial pop. sizes for the 3 stages plus the facilitator species
facindex <- c(0,1.2)            # this will be the values by which facilitator decreases seeds and seedlings deathrates
effects <- c(0,0,0, 0,-0.5,0, 0,0,-1) # the effects reducing deathrate (negative values increase deathrates)
radius <- c(0,0.2,2,3)        # this are the distances up to which the individuals can have effect on others, by stage + facilitator
h <- 100                       # arena height
w <- 100                       # arena width

wrapper <- function(disp,eff,maxt,details,slope,name){ set.seed(321)
	results <- facByRates(maxt, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=disp, R=reproductionrate, 
		   interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w,maxstresseffects=c(0,eff,0),maxinteractionvar=slope)
save(results,file="run.RData")

	times <- seq(0,maxt,length.out=details)         # array of times of interest
	ab <- abundance_matrix(results,times)
	stackplot(ab[,1:3])
	savePlot(paste0(name,".png"))
	saveGIF(spatialplot(results,times),interval=0.1,movie.name=paste0(name,".gif")) 
}


