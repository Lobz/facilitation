
Sys.setenv("PKG_LIBS"="-lprofiler")

load_all()
maxt<-10
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

neutral<-idealsim(800)

