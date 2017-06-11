
numstages <- n
deathrates <- runif(n,0.1,1.0)  # death rates for seed, sapling and adult
growthrates <- runif(n-1,0.2,2.4)      # transition rates seed-->sapling and sapling-->adult
reproductionrate <- 12        # reproduction rate (only adult)
dispersalradius <- 1.5          # average distance a seed falls from the parent (distance is gaussian)
times <- seq(0,25,length.out=60)         # array of times of interest
initialpop <- c(rep(0,n-1),10,10)    # initial pop. sizes for the 3 stages plus the facilitator species
facindex <- runif(n-1,0,1.5)            # this will be the values by which facilitator decreases seeds and seedlings deathrates
effects <- rep(0,n*n) # the effects reducing deathrate (negative values increase deathrates)
radius <- sort(rexp(n+1,1))        # this are the distances up to which the individuals can have effect on others, by stage + facilitator
h <- 40                       # arena height
w <- 40                       # arena width

dt1 <- facilitation(times=times, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, 
		 interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w,facilitatorD=.1,facilitatorR=.3,facilitatorC=.3)
ab1 <- abundance.matrix(dt1$data)
stackplot(ab1[,1:n])
savePlot("moarstages.png")
spatialanimation(dt1,interval=0.1,movie.name="moarstages.gif") 
