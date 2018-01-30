library(facilitation)
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
    par <- c(4,1,0,0,1, 1,0,5.5,dispersal,2)
    param <- matrix(rep(par,nsp)
                    , byrow=T, nrow=sum(nstages))
    sapsap <- -2
    adusap <- 0
    intersap <- rep(c(sapsap,adusap),nsp)
    aduadu <- 0
    sapadu <- 0
    interadu <- rep(c(sapadu,aduadu),nsp)
    interact <- matrix(c(rep(c(intersap,interadu),nsp)),ncol=totstages)

    neutral <- community(maxt,nstages,param,init,interactionsD=interact,h=h,w=w)

    save(neutral,file="test.RData")

    neutral
}

inter00 <- c(intersap,interadu) # 1-100 no receive, no give
inter01 <- c(intersapfac,interadu) # 101-200 receive, no give
inter10 <- c(intersap,interadu) # 201-300 no receive, give
inter11 <- c(intersapfac,interadu) # 301-400 receive, give

