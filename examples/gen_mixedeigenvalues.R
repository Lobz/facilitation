numstages <- 3
#"7",0.28025,0.80875,0.43825,0.35825,0.08675,0.42625,0.69525,0.8645,-0.303056776942289,0.106036336472297,"mixed"
deathrates <- c(0.28025,0.80875,0.43825)  # death rates for seed, sapling and adult
growthrates <- c(0.35865,0.0875)      # transition rates seed-->sapling and sapling-->adult
reproductionrate <- 3.6        # reproduction rate (only adult)
dispersalradius <- 0.5          # average distance a seed falls from the parent (distance is gaussian)
times <- seq(5,20,0.2)         # array of times of interest
initialpop <- c(100,100,0,10)	# initial pop. sizes for the 3 stages plus the facilitator species
facindex <- c(0,0.8)            # this will be the values by which facilitator decreases seeds and seedlings deathrates
effects <- c(0,0,0, 0,-0.3,0, 0,0,-0.22) # the effects reducing deathrate (negative values increase deathrates)
radius <- c(0,0.2,2,3)        # this are the distances up to which the individuals can have effect on others, by stage + facilitator
h <- 50                       # arena height
w <- 50                       # arena width

dt <- facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, 
		 interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)

dt$data <- subset(dt$data,t>0)
ab <- abundance_matrix(dt$data)
stackplot(ab[,1:3])
saveGIF(spatialplot(dt),interval=0.1,movie.name="disperse.gif") 
