library(animation)
numstages <- 3
deathrates <- c(2, 1.2, 0.6)  # death rates for seed, sapling and adult
growthrates <- c(1, 0.2)      # transition rates seed-->sapling and sapling-->adult
reproductionrate <- 10        # reproduction rate (only adult)
dispersalradius <- 1.2          # average distance a seed falls from the parent (distance is gaussian)
times <- seq(0,120,length.out=60)         # array of times of interest
initialpop <- c(0,0,15,10)    # initial pop. sizes for the 3 stages plus the facilitator species
facindex <- c(0,1)            # this will be the values by which facilitator decreases seeds and seedlings deathrates
effects <- c(0,0,0, 0,-0.5,0, 0,0,-0.2) # the effects reducing deathrate (negative values increase deathrates)
radius <- c(0,0.2,2,3)        # this are the distances up to which the individuals can have effect on others, by stage + facilitator
h <- 40                       # arena height
w <- 40                       # arena width

dispersalradius <- 0.2          # average distance a seed falls from the parent (distance is gaussian)
dt1 <- facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, 
		 interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)

ab1 <- abundance_matrix(dt1$data)
stackplot(ab1[,1:3])
savePlot("disperse1.png")

dispersalradius <- 1.5          # average distance a seed falls from the parent (distance is gaussian)
dt2 <- facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, 
		 interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)

ab2 <- abundance_matrix(dt2$data)
stackplot(ab2[,1:3])
savePlot("disperse2.png")

dispersalradius <- 3          # average distance a seed falls from the parent (distance is gaussian)
dt3 <- facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, 
		 interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)

ab3 <- abundance_matrix(dt3$data)
stackplot(ab3[,1:3])
savePlot("disperse3.png")

dispersalradius <- 6          # average distance a seed falls from the parent (distance is gaussian)
dt4 <- facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, 
		 interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)

ab4 <- abundance_matrix(dt4$data)
stackplot(ab4[,1:3])
savePlot("disperse4.png")

dispersalradius <- 12          # average distance a seed falls from the parent (distance is gaussian)
dt5 <- facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, 
		 interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)

ab5 <- abundance_matrix(dt5$data)
stackplot(ab5[,1:3])
savePlot("disperse5.png")

col <- colorRampPalette(c("red","blue4"))(5)
y = c(0,max(c(rowSums(ab1),rowSums(ab2),rowSums(ab3),rowSums(ab4),rowSums(ab5))))
plot(rowSums(ab5)~rownames(ab5),ylim=y,xlim=c(min(times),max(times)),type="l",lwd=1.2,ylab="População",xlab="Tempo",col=col[5],main="Efeito da dispersão")
lines(rowSums(ab4)~rownames(ab4),col=col[4])
lines(rowSums(ab3)~rownames(ab3),col=col[3])
lines(rowSums(ab2)~rownames(ab2),col=col[2])
lines(rowSums(ab1)~rownames(ab1),col=col[1])
legend("topleft", legend=c("12","6","3","1.5","0.2"), fill=rev(col))
savePlot("dispersesumK.png")

fitlm <- function(ab){coef(lm(rowSums(ab[,1:3])~as.numeric(rownames(ab))))[2]}
rates <- c(0,0,0,0,0)
rates[1] <- fitlm(ab1)
rates[2] <- fitlm(ab2)
rates[3] <- fitlm(ab3)
rates[4] <- fitlm(ab4)
rates[5] <- fitlm(ab5)
