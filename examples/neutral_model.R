library(facilitation)
maxt<-60
dispersal<-10

### n species two stages competition 
### with these par, 10x10 arena, ~150 individuals
idealsim <- function(nind){

    area<-nind/1.5
    h<-w<-sqrt(area)
    nsp <- floor(nind/20) # floor because less is better than more
    nst <- 2
    init <- c(10,10)
    nstages <- rep(nst,nsp)
    totstages <- nst*nsp
    init <- rep(list(init),nsp)
    par <- c(2,1,0,1, 1,0,5,2)
    param <- matrix(rep(par,nsp)
                    , byrow=T, nrow=sum(nstages)) 
    sapsap <- -1
    adusap <- 0
    intersap <- rep(c(sapsap,adusap),nsp)
    aduadu <- 0
    sapadu <- 0
    interadu <- rep(c(sapadu,aduadu),nsp)
    interact <- matrix(c(rep(c(intersap,interadu),nsp)),ncol=totstages)

    neutral <- community(maxt,nstages,param,dispersal,init,interactions=interact,h=h,w=w)

    neutral
}



save(neutral,"neutral.RData")

par(mfrow=c(2,2))
a<-abundance.matrix(neutral)
stackplot(a,main="neutral")
last<- c(abundance.matrix(neutral,neutral$maxtime)[,(1:nsp)*nst])
plot(sort(last))
plotsnapshot(neutral,neutral$maxtime)

adusapfac <- +.1
intersapfac <- c(rep(c(sapsap,adusap),nsp/2),rep(c(sapap,adusapfac),nsp/2)) # receive from half

inter00 <- c(intersap,interadu) # 1-100 no receive, no give
inter01 <- c(intersapfac,interadu) # 101-200 receive, no give
inter10 <- c(intersap,interadu) # 201-300 no receive, give
inter11 <- c(intersapfac,interadu) # 301-400 receive, give


facil <- community(maxt,nstages,param,dispersal,init,interactions=interact,maxpop=300000)
a<-abundance.matrix(facil)
stackplot(a,main="facil")
last<- c(abundance.matrix(facil,facil$maxtime)[,(1:nsp)*nst])
plot(sort(last))
plotsnapshot(facil,facil$maxtime)
