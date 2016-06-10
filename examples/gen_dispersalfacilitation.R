library(animation)
#1/(2+1)=1/3
#.2/(.2+1.4)=1/8
#s=1/24
#Rs=.25
#.2/(.2+.2)=1/2
#s=1/6
#Rs=1
numstages <- 3
deathrates <- c(2, 1.4, 0.5)  # death rates for seed, sapling and adult
growthrates <- c(1, 0.2)      # transition rates seed-->sapling and sapling-->adult
reproductionrate <- 6        # reproduction rate (only adult)
dispersalradius <- 1.2          # average distance a seed falls from the parent (distance is gaussian)
initialpop <- c(0,0,15,10)    # initial pop. sizes for the 3 stages plus the facilitator species
facindex <- c(0,1.2)            # this will be the values by which facilitator decreases seeds and seedlings deathrates
effects <- c(0,0,0, 0,-0.5,0, 0,0,-1) # the effects reducing deathrate (negative values increase deathrates)
radius <- c(0,0.2,2,3)        # this are the distances up to which the individuals can have effect on others, by stage + facilitator
h <- 40                       # arena height
w <- 40                       # arena width

maxt <- 150
maxt=5
wrapper <- function(disp){ set.seed(1234)
	facByRates(maxt, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=disp, R=reproductionrate, 
		 interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)}

library(parallel)

dispersions <- .2*2^(1:6)
results <- mclapply(dispersions,wrapper)

details=10
times <- seq(0,maxt,length.out=details)         # array of times of interest
abmatrices <- mclapply(results,function(r){abundance_matrix(r,times)[,1:3]})

poptots <- lapply(abmatrices,rowSums)
# PLOT TOGHETER 
colors <- colorRampPalette(c("red","blue4"))(length(dispersions))

maxpop = max(lapply(poptots,max))
plot(NULL,NULL,ylim=c(0,maxpop),xlim=c(0,maxt),ylab="População",xlab="Tempo",main="População total para raios de dispersão variados")

for(i in 1:length(dispersions)){
	x <- poptots[[i]]
	lines(x~times,col=colors[i],lwd=1.2)
}

legend("topleft", legend=dispersions, fill=colors)
savePlot("dispersesumK.png")
