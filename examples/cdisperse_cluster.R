### This script generates a comparison plot between simulations with different dispersal rates
#1/(2+1)=1/3
#.2/(.2+1.2)=1/7
#s=1/21
#Rs=1/3=.33'
#.2/(.2+.2)=1/2
#s=1/6
#Rs=1
wrapper <- function(disp){
    numstages <- 3
    deathrates <- c(2, 1.4, 0.5)  # death rates for seed, sapling and adult
    growthrates <- c(1, 0.2)      # transition rates seed-->sapling and sapling-->adult
    reproductionrate <- 7        # reproduction rate (only adult)
    facindex <- c(0,1.2)            # this will be the values by which facilitator decreases seeds and seedlings deathrates
    effects <- c(0,0,0, 0,-0.5,0, 0,0,-1) # the effects reducing deathrate (negative values increase deathrates)
    radius <- c(0,0.2,1,2)        # this are the distances up to which the individuals can have effect on others, by stage + facilitator
    h <- 100                       # arena height
    w <- 100                       # arena width
    d<-generate.overdisperse(4,4.7,height=h,width=w) # generate initial facilitator distribution 
    if(nrow(d)>200)d<-d[sample(1:nrow(d),200),]
    i<-initial.distribution(c(400,0,0),min.id=max(d$id)+1,height=h,width=w) # generate initial population for facilitated
    initialpop <- rbind(d,i)
    maxt <- 50
    facilitation(maxt, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=disp, R=reproductionrate, 
                 interactions=effects, fac=facindex, init=initialpop, radius=radius, height=h, width=w)}


ndisps <- 10
mindisp <- .25
disprate <- 2
dispersions <- mindisp*disprate^(0:(ndisps-1))
nreps <- 5
dispvec <- rep(dispersions,nreps)

library(parallel)
cl = makePSOCKcluster(machinefile("mpd.hosts"))

clusterEvalQ(cl,library(facilitation))
clusterExport(cl,"wrapper")
results <- parLapply(cl,dispvec,wrapper)

details=50
times <- seq(5,maxt,length.out=details)         # array of times of interest
clusterExport(cl,"times")
abmatrices <- parLapply(cl,results,function(r){abundance.matrix(r,times)[,1:3]})

poptots <- parLapply(cl,abmatrices,rowSums)
poptots <- parLapply(cl,abmatrices,function(a){a[,3]})

stopCluster(cl)

# PLOT TOGHETER 
png("compareandregress.png")
par(mfrow=c(1,1))
colors <- colorRampPalette(c("red","blue4"))(ndisps)

maxpop = max(sapply(poptots,max))
plot(NULL,NULL,ylim=c(0,maxpop),xlim=c(0,maxt),ylab="População",xlab="Tempo",main="População total para raios de dispersão variados")

for(i in 1:ndisps){
    for(j in 1:nreps-1){
       x <- poptots[[i+ndisps*j]]
        lines(x~times,col=colors[i],lwd=1.2)
    }
}

legend("topleft", legend=dispersions, fill=colors)

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
dev.off()

png("fits.png")
par(mfrow=c(2,1))
barplot(fits[1,],names.arg=dispersions,col=colors,main="r")
barplot(fits[2,],names.arg=dispersions,col=colors,main="K")
par(mfrow=c(1,1))
dev.off()

plotgif <- function(i){
    details=50
    times <- seq(5,maxt,length.out=details)         # array of times of interest
    spatialanimation(results[[i]],times,interval=0.1,movie.name=paste0("df",i,".gif"))
}

for(i in 1:length(dispersions)){
    plotgif(i)
}

fits
