numstages <- 3
#.5/(.5+1)=1/3
#.05/(.5+.05)=1/11
#s=1/33
#Rs=.06
#.05/(.3+.05)=1/7
#s=1/21
#Rs=.1
deathrates <- c(1,0.5,0.1)  # death rates for seed, sapling and adult
growthrates <- c(0.1,0.05)      # transition rates seed-->sapling and sapling-->adult
reproductionrate <-  2       # reproduction rate (only adult)
dispersalradius <- 0.2          # average distance a seed falls from the parent (distance is gaussian)
initialpop <- c(0,0,20,0)	# initial pop. sizes for the 3 stages plus the facilitator species
facindex <- c(0,0.2)            # this will be the values by which facilitator decreases seeds and seedlings deathrates
effects <- c(0,0,0, 0,-0.5,0, 0,0,-1.5) # the effects reducing deathrate (negative values increase deathrates)
radius <- c(0,0.2,2,3)        # this are the distances up to which the individuals can have effect on others, by stage + facilitator
h <- 40                       # arena height
w <- 40                       # arena width
maxtime <- 100

dt1 <- facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, 
		 interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)

times <- seq(0,60,length.out=80)         # array of times of interest
dt1$data <- subset(dt1$data,t>0)
ab1 <- abundance_matrix(dt1$data)
stackplot(ab1[,1:3])
savePlot("disperse1.png")
saveGIF(spatialplot(dt1),interval=0.1,movie.name="disperse1.gif") 

dispersalradius <- 1.5          # average distance a seed falls from the parent (distance is gaussian)
dt2 <- facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, 
		 interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)

dt2$data <- subset(dt2$data,t>0)
ab2 <- abundance_matrix(dt2$data)
stackplot(ab2[,1:3])
savePlot("disperse2.png")
saveGIF(spatialplot(dt2),interval=0.1,movie.name="disperse2.gif") 

dispersalradius <- 3          # average distance a seed falls from the parent (distance is gaussian)
dt3 <- facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, 
		 interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)

dt3$data <- subset(dt3$data,t>0)
ab3 <- abundance_matrix(dt3$data)
stackplot(ab3[,1:3])
savePlot("disperse3.png")
saveGIF(spatialplot(dt3),interval=0.1,movie.name="disperse3.gif") 

dispersalradius <- 6          # average distance a seed falls from the parent (distance is gaussian)
dt4 <- facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, 
		 interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)

dt4$data <- subset(dt4$data,t>0)
ab4 <- abundance_matrix(dt4$data)
stackplot(ab4[,1:3])
savePlot("disperse4.png")
saveGIF(spatialplot(dt4),interval=0.1,movie.name="disperse4.gif") 

dispersalradius <- 12          # average distance a seed falls from the parent (distance is gaussian)
dt5 <- facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, 
		 interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)

dt5$data <- subset(dt5$data,t>0)
ab5 <- abundance_matrix(dt5$data)
stackplot(ab5[,1:3])
savePlot("disperse5.png")
saveGIF(spatialplot(dt5),interval=0.1,movie.name="disperse5.gif") 

col <- colorRampPalette(c("red","blue4"))(5)
plot(rowSums(ab5)~rownames(ab5),type="l",lwd=1.2,ylab="População",xlab="Tempo",col=col[5],main="Efeito da dispersão")
lines(rowSums(ab4)~rownames(ab4),col=col[4])
lines(rowSums(ab3)~rownames(ab3),col=col[3])
lines(rowSums(ab2)~rownames(ab2),col=col[2])
lines(rowSums(ab1)~rownames(ab1),col=col[1])
legend("topleft", legend=c("12","6","3","1.5","0.2"), fill=rev(col))
savePlot("dispersesumK.png")

