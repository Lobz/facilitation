
maxt<-60

neutralsimD <- function(nads){

    area<-nads/.12
    nsp <- floor(nads/10) # floor because less is better than more

    dispersal<-30
    h<-w<-sqrt(area)
    nst <- 2
    init <- c(10,10)
    nstages <- rep(nst,nsp)
    totstages <- nst*nsp
    init <- rep(list(init),nsp)
    par <- c(4,1,0,1, 1,0,5.5,2)
    param <- matrix(rep(par,nsp)
                    , byrow=T, nrow=sum(nstages))
    sapsap <- -2
    adusap <- 0
    intersap <- rep(c(sapsap,adusap),nsp)
    aduadu <- 0
    sapadu <- 0
    interadu <- rep(c(sapadu,aduadu),nsp)
    interact <- matrix(c(rep(c(intersap,interadu),nsp)),ncol=totstages)

    neutral <- community(maxt,nstages,param,dispersal,init,interactionsD=interact,h=h,w=w)

    save(neutral,file="test.RData")

    neutral
}

n <- neutralsimD(400)
nsp <- n$num.pop
adults <- 1:nsp*2
juvs <- adults-1
b<-abundance.matrix(n,seq(10,n$maxtime,length.out=20))
bads<-b[,adults]
summary(c(b[ ,juvs]/bads)) # average juv:adult ratio
summary(rowSums(bads/(n$h*n$w))) # number of adults per square unit
summary(rowSums(bads)) # should average very close to the expected number
summary(rowSums(b)) # estimate of number of individuals
stackplot(bads)

neutralsimG <- function(nads){

    area<-nads/.12
    nsp <- floor(nads/10) # floor because less is better than more

    dispersal<-30
    h<-w<-sqrt(area)
    nst <- 2
    init <- c(45,10)
    nstages <- rep(nst,nsp)
    totstages <- nst*nsp
    init <- rep(list(init),nsp)
    par <- c(2,4,0,1, 1,0,10,2)
    param <- matrix(rep(par,nsp)
                    , byrow=T, nrow=sum(nstages))

    # growthrate interaction
    sapsap <- 0
    adusap <- -4 # saplings cannot become adults under an adult 
    intersap <- rep(c(sapsap,adusap),nsp)
    aduadu <- 0
    sapadu <- 0
    interadu <- rep(c(sapadu,aduadu),nsp)
    interactG <- matrix(c(rep(c(intersap,interadu),nsp)),ncol=totstages)


    neutral <- community(maxt,nstages,param,dispersal,init,interactionsG=interactG,h=h,w=w)

    save(neutral,file="test.RData")

    neutral
}

n <- neutralsimG(400)
nsp <- n$num.pop
adults <- 1:nsp*2
juvs <- adults-1
b<-abundance.matrix(n,seq(10,n$maxtime,length.out=20))
bads<-b[,adults]
summary(c(b[ ,juvs]/bads)) # average juv:adult ratio
summary(rowSums(bads/(n$h*n$w))) # number of adults per square unit
summary(rowSums(bads)) # should average very close to the expected number
summary(rowSums(b)) # estimate of number of individuals
stackplot(bads)


adultpops <- function(model,t) {
    pop<-c(abundance.matrix(model,t)[,(1:nsp)*nst])
    pop<-pop[pop>0]
    pop
}

neutral<-neutralsim(200)

nsp<-neutral$num.pop
nst<-neutral$num.stages[1]
#neutral$radius <- rep(c(.2,.4),nsp)
a<-abundance.matrix(neutral)
stackplot(a)
last<- adultpops(neutral,neutral$maxtime)
plot(sort(last))
plotsnapshot(neutral,neutral$maxtime)

library(sads)
pops<-adultpops(neutral,60)
plot(octav(adultpops(neutral,50)))

adultpops(neutral,30)->pops



