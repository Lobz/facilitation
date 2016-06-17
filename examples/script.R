load_all()
numstages <- 3
deathrates <- c(2, 0.2, 0.2)  # death rates for seed, sapling and adult
growthrates <- c(1, 0.2)      # transition rates seed-->sapling and sapling-->adult
reproductionrate <- 10        # reproduction rate (only adult)
dispersalradius <- 2          # average distance a seed falls from the parent (distance is gaussian)
t <- 10
initialpop <- c(1,1,10,20)    # initial pop. sizes for the 3 stages plus the facilitator species
facindex <- c(0,1)            # this will be the values by which facilitator decreases seeds and seedlings deathrates
effects <- c(0,0,0, 0,-0.5,0, 0,0,-0.2) # the effects reducing deathrate (negative values increase deathrates)
radius <- c(0,0.5,2,2)        # this are the distances up to which the individuals can have effect on others, by stage + facilitator
h <- 50                       # arena height
w <- 50                       # arena width

dt <- facByRates(maxtime=t, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, 
		 R=reproductionrate, interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)
