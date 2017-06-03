### This script generates a comparison plot between simulations with different dispersal rates
### Nota: this is the ne used in the presentations 2016/2017 
library(animation)
#1/(2+1)=1/3
#.2/(.2+1.2)=1/7
#s=1/21
#Rs=2/7=.28
#.2/(.2+.2)=1/2
#s=1/6
#Rs=1
numstages <- 3
deathrates <- c(2, 1.4, 0.5)  # death rates for seed, sapling and adult
growthrates <- c(1, 0.2)      # transition rates seed-->sapling and sapling-->adult
reproductionrate <- 6        # reproduction rate (only adult)
initialpop <- c(0,0,200,100)    # initial pop. sizes for the 3 stages plus the facilitator species
facindex <- c(0,1.2)            # this will be the values by which facilitator decreases seeds and seedlings deathrates
effects <- c(0,0,0, 0,-0.5,0, 0,0,-1) # the effects reducing deathrate (negative values increase deathrates)
radius <- c(0,0.2,2,3)        # this are the distances up to which the individuals can have effect on others, by stage + facilitator
h <- 100                       # arena height
w <- 100                       # arena width

maxt <- 250
wrapper <- function(disp){ set.seed(5)
facilitation(maxt, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=disp, R=reproductionrate, 
             interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)}

library(parallel)

dispersions <- .2*2^(0:6)
results <- mclapply(dispersions,wrapper)

details=400
times <- seq(5,maxt,length.out=details)         # array of times of interest
abmatrices <- mclapply(results,function(r){abundance.matrix(r,times)[,1:3]})

poptots <- lapply(abmatrices,rowSums)

# PLOT TOGHETER 
colors <- colorRampPalette(c("red","blue4"))(length(dispersions))

maxpop = max(sapply(poptots,max))
plot(NULL,NULL,ylim=c(0,maxpop),xlim=c(0,maxt),ylab="População",xlab="Tempo",main="População total para raios de dispersão variados")

for(i in 1:length(dispersions)){
    x <- poptots[[i]]
    lines(x~times,col=colors[i],lwd=1.2)
}

legend("topleft", legend=dispersions, fill=colors)
savePlot("dispersesumK.png")

#FIT STUFF
logisticgrowth <- function(r,K,N0,t){ ((K*N0*exp(r*t))/(K-N0+N0*exp(r*t))) }
mat <- mat.model(n=numstages,Ds=deathrates-c(facindex,0),Gs=growthrates,R=reproductionrate)
intr <- limiting.rate(mat) 
fit.data.log <- function(pop) { tryCatch(nls(pop~logisticgrowth(r,K,N0,times),start=list(r=intr,K=maxpop,N0=80)),error=function(e) NA)}
reglog <- function(dt){tryCatch(coef(fit.data.log(dt)),error=function(e){ c(NA,NA,NA) })}

fits <- sapply(poptots,reglog)	
fits

for(i in 1:length(dispersions)){
    c <- fits[,i]
    x <- logisticgrowth(c[1],c[2],c[3],times)
    lines(x~times,col=colors[i],lty=2)
}
savePlot("dispersesumKregressed.png")

plotgif <- function(i){
    details=50
    times <- seq(5,maxt,length.out=details)         # array of times of interest
    saveGIF(spatialplot(results[[i]],times),interval=0.1,movie.name=paste0("df",i,".gif"))
}

for(i in 1:length(dispersions)){
    plotgif(i)
}

