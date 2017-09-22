### starting a new script, with only one stage, one species, very simple    

library(facilitation)

### Logistic one species one stage
nstages <- 1
des.r <- 1.0 # births - deaths .. adimensionalized
radius <- 1.0 # adimensionalize this too
### non adimensionalized ones
D <- 1.0
R <- des.r + D 
n0 <- 10
compet <- -.5 

### Logistic one species one stage test effect of spacialization
### N' = (R - D)N - cN² =====> K = r/c
des.K <- 1000
radius <- 100 # interact with everyone
compet <- des.r/des.K ### 1/1000 = .001

wrapper <- function(compet) {
    initial.obj$interactions <- matrix(c(compet),ncol=nstages)
    proceed(initial.obj,maxt)
}

wrapper <- function(disp){
    if(disp<0){
        disp<-1
        initial.obj$dispKernel<-"random"
    }
    else {
        initial.obj$dispKernel<-"exponential"
    }
    initial.obj$dispersal<-disp
    r <- proceed(initial.obj,maxt)
    
   
    r
}


param <- matrix(c(D,0,R,radius),nrow=nstages,byrow=T)
interact <- matrix(c(compet),ncol=nstages)
initial.obj <- community(0,nstages,param,dispersal=0,init=n0,interactions=interact,h=50,w=50)

ndisps <- 10
mindisp <- .25
disprate <- 2
dispersions <- c(mindisp*disprate^(0:(ndisps-1)),-1)
ndisps <- ndisps+1
nreps <- 5
dispvec <- rep(dispersions,nreps)

maxt <- 50

library(parallel)
cl = makePSOCKcluster(machinefile("mpd.hosts"))

clusterEvalQ(cl,library(facilitation))
clusterExport(cl,"wrapper")
clusterExport(cl,"initial.obj")
clusterExport(cl,"maxt")
results <- parLapply(cl,dispvec,wrapper)

details=500
times <- seq(0,results[[1]]$maxtime,length.out=details)         # array of times of interest
clusterExport(cl,"times")

abmatrices <- parLapply(cl,results,function(r){abundance.matrix(r,times)})

abgrouped <- lapply(dispersions,function(d){abmatrices[dispvec==d]})
abjoined <-lapply(abgrouped,function(group){do.call("cbind",group)})
abaverage <- lapply(abjoined,function(m){rowSums(m)/nreps})

stopCluster(cl)

# PLOT TOGHETER 
png("compareandregress.png")
par(mfrow=c(1,1))
colors <- colorRampPalette(c("red","blue4"))(ndisps)

maxpop = max(sapply(abmatrices,max))
plot(NULL,NULL,ylim=c(0,maxpop),xlim=c(0,maxt),ylab="População",xlab="Tempo",main="População total para raios de dispersão variados")

for(i in 1:ndisps){
    for(j in 1:nreps){
       x <- abgrouped[[i]][[j]]
        lines(x~times,col=colors[i],lwd=1.2)
    }
}

for(i in 1:10){
    x<-logisticgrowth(fits[1,i],fits[2,i],10,times)
    lines(x~times)
}


legend("topleft", legend=dispersions, fill=colors)

#FIT STUFF
logisticgrowth <- function(r,K,N0,t){ (1.0*K/((K-N0)*exp(-r*t)/N0 +1)) }

fit.data.log <- function(pop) {nls(pop~logisticgrowth(r,K,10,as.numeric(rownames(pop))),start=list(r=1,K=maxpop))}
reglog <- function(dt){tryCatch(coef(fit.data.log(dt)),error=function(e){ c(NA,NA) })}

ll <- function(ab, r, K, 




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
