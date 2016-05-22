library(animation)
numstages <- 3
deathrates <- c(2, .2, 0.6)  # death rates for seed, sapling and adult
growthrates <- c(1, 0.2)      # transition rates seed-->sapling and sapling-->adult
reproductionrate <- 10        # reproduction rate (only adult)
dispersalradius <- 1.2          # average distance a seed falls from the parent (distance is gaussian)
times <- seq(0,5,length.out=6)         # array of times of interest
initialpop <- c(0,0,10,0)    # initial pop. sizes for the 3 stages plus the facilitator species
facindex <- c(0,1)            # this will be the values by which facilitator decreases seeds and seedlings deathrates
effects <- c(0,0,0, 0,-0.5,0, 0,0,-0.2) # the effects reducing deathrate (negative values increase deathrates)
radius <- c(0,0.2,2,3)        # this are the distances up to which the individuals can have effect on others, by stage + facilitator
h <- 40                       # arena height
w <- 40                       # arena width

dispersalradius <- 40          # average distance a seed falls from the parent (distance is gaussian)
dt <- facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, 
		 interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)

ab <- abundance_matrix(dt)
stackplot(ab[,1:3])
saveGIF(spatialplot(dt),interval=0.1,movie.name="testedispersão.gif") 
