load_all()
numstages <- 3
deathrates <- c(2, 0.2, 0.2)  # death rates for seed, sapling and adult
growthrates <- c(1, 0.2)      # transition rates seed-->sapling and sapling-->adult
reproductionrate <- 10        # reproduction rate (only adult)
dispersalradius <- 2          # average distance a seed falls from the parent (distance is gaussian)
t <- 10
initialpop <- c(100,100,100,0)    # initial pop. sizes for the 3 stages plus the facilitator species
facindex <- c(0,1)            # this will be the values by which facilitator decreases seeds and seedlings deathrates
effects <- c(0,0,0, 0,-0.5,0, 0,0,-0.2) # the effects reducing deathrate (negative values increase deathrates)
radius <- c(0,0.5,2,2)        # this are the distances up to which the individuals can have effect on others, by stage + facilitator
h <- 50                       # arena height
w <- 50                       # arena width

results <- facByRates(maxtime=t, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, 
		 R=reproductionrate, init=initialpop, rad=radius, h=h, w=w)
times <- seq(0,t,length.out=100)
ab <- abundance_matrix(results,times)[,1:numstages]
mat <- mat.model(n=numstages,Ds=deathrates,Gs=growthrates,R=reproductionrate)
so <- solution.matrix(p0=initialpop[1:numstages], M=mat, times=times)

stackplot(ab, main="Dinâmica Populacional")
lines(so[,3]~rownames(so),lty=3)
lines(so[,3]+so[,2]~rownames(so),lty=3)
lines(so[,3]+so[,2]+so[,1]~rownames(so),lty=3)
savePlot("plot1.png")

stackplot(ab, log.y=T, main="Dinâmica Populacional (escala log)")
lines(so[,3]~rownames(so),lty=3)
lines(so[,3]+so[,2]~rownames(so),lty=3)
lines(so[,3]+so[,2]+so[,1]~rownames(so),lty=3)
savePlot("plot2.png")

props<- ab/rowSums(ab)
so<- so/rowSums(so)
stackplot(props,main="Proporção Etária")
lines(so[,3]~rownames(so),lty=3)
lines(so[,3]+so[,2]~rownames(so),lty=3)
savePlot("plot3.png")


