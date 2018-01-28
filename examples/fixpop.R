
maxt<-30

fixpopsim <- function(nind){

    area<-nind/.98
    h<-w<-sqrt(area)
    nsp <- floor(nind/20) # floor because less is better than more
    dispersal<-30
    nst <- 2
    init <- c(16,4)
    nstages <- rep(nst,nsp)
    totstages <- nst*nsp
    init <- rep(list(init),nsp)
    par <- c(10,2,0,1, 1,0,50,2)
    param <- matrix(rep(par,nsp)
                    , byrow=T, nrow=sum(nstages))
    # deathrate
    sapsap <- -1
    adusap <- 0
    intersap <- rep(c(sapsap,adusap),nsp)
    aduadu <- 0
    sapadu <- 0
    interadu <- rep(c(sapadu,aduadu),nsp)
    interactD <- matrix(c(rep(c(intersap,interadu),nsp)),ncol=totstages)

    # growthrate
    sapsap <- 0
    adusap <- -1
    intersap <- rep(c(sapsap,adusap),nsp)
    aduadu <- 0
    sapadu <- 0
    interadu <- rep(c(sapadu,aduadu),nsp)
    interactG <- matrix(c(rep(c(intersap,interadu),nsp)),ncol=totstages)

    # reproductionrate
    sapsap <- 0
    adusap <- 0
    intersap <- rep(c(sapsap,adusap),nsp)
    aduadu <- -1
    sapadu <- 0
    interadu <- rep(c(sapadu,aduadu),nsp)
    interactR <- matrix(c(rep(c(intersap,interadu),nsp)),ncol=totstages)

    neutral <- community(maxt,nstages,param,dispersal,init,
                         interactionsD=interactD,interactionsG=interactG,interactionsR=interactR,
                         h=h,w=w)

    neutral
}

# a simple test
n<-fixpopsim(400)
b<-abundance.matrix(n,seq(10,n$maxtime,length.out=20))
summary(c(b[ ,1:n$num.pop*2-1]/b[,1:n$num.pop*2])) # average juv:adult ratio
summary(rowSums(b/(n$h*n$w))) # number of individuals per square unit
summary(rowSums(b)) # should average very close to the expected number
stackplot(b)
