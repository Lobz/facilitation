### starting a new script, with only one stage, one species, very simple    


### Logistic one species one stage
nstages <- 1
r <- 1 # births - deaths .. adimensionalized
radius <- 1 # adimensionalize this too
### non adimensionalized ones
D <- 1
R <- r + D 
n0 <- 100
compet <- -.5 

param <- matrix(c(D,0,R,radius),nrow=nstages,byrow=T)
interact <- matrix(c(compet),ncol=nstages)
initial.obj <- community(0,nstages,param,dispersal=0,init=n0,interactions=interact,h=30,w=30)

wrapper <- function(disp){
    initial.obj$dispersal<-disp
    t <- system.time(r <- proceed(initial.obj,1))
    while(r$maxtime < maxt && max(t) < 900)
        t <- system.time(r <- proceed(r,1))
    r
}

ndisps <- 10
mindisp <- .25
disprate <- 2
dispersions <- mindisp*disprate^(0:(ndisps-1))
nreps <- 5
dispvec <- rep(dispersions,nreps)

maxt <- 5

library(parallel)
cl = makePSOCKcluster(machinefile("mpd.hosts"))

clusterEvalQ(cl,library(facilitation))
clusterExport(cl,"wrapper")
clusterExport(cl,"initial.obj")
clusterExport(cl,"maxt")
results <- parLapply(cl,dispvec,wrapper)
results <- parLapply(cl,results,function(r) proceed(r,100))

details=500
times <- seq(5,results[[1]]$maxtime,length.out=details)         # array of times of interest
clusterExport(cl,"times")
abmatrices <- parLapply(cl,results,function(r){abundance.matrix(r,times)})

abjoined <-lapply(dispersions,function(d){do.call("rbind",abmatrices[dispvec==d])})

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
fit.data.log <- function(pop) {nls(pop~logisticgrowth(r,K,N0,as.numeric(names(pop))),start=list(r=intr,K=maxpop,N0=80))}
reglog <- function(dt){tryCatch(coef(fit.data.log(dt)),error=function(e){ c(NA,NA,NA) })}

fits <- sapply(poptots,reglog)	
fits
fits <- sapply(popjoined,reglog)
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
