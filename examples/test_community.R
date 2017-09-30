maxt <- 30
dispersal<-20

results<-list()

### Simple mathusian one species
nstages <- 3
init <- c(0,0,100)
param <- matrix(c(5,1,0, 1,1,0, .5,0,10),nrow=3,byrow=T)
results$malth1 <- community(maxt,nstages,param,dispersal,init)

### Simple malthusian two species
nstages <- c(3,2)
init <- list(c(100,0,10),c(100,30))
param <- matrix(c(2,1,0, 1,1,0, .5,0,6, 1,1,0, .5,0,2), byrow=T, nrow=5) 
results$malth2 <- community(maxt,nstages,param,dispersal,init)

### Logistic one species
nstages <- 3
init <- c(0,0,100)
param <- matrix(c(5,1,0,0, 1,1,0,0, .5,0,10,2),nrow=3,byrow=T)
interact <- matrix(c(0,0,0,0,0,0,0,0,-.1),ncol=3)
results$compet1 <- community(maxt,nstages,param,dispersal,init,interactionsD=interact)

### Two species competition (different is better)
nstages <- c(3,2)
init <- list(c(100,0,10),c(100,30))
param <- matrix(c(2,1,0,0, 1,1,0,.1, .5,0,6,1, 1,1,0,.2, .5,0,2,2), byrow=T, nrow=5) 
interact <- matrix(c(0,0,0,0,0, 0,0,0,0,0, 0,0,-.05,0,-.2, 0,0,0,0,0, 0,0,-.05,0,-.1),ncol=5)
results$compet2diff <- community(maxt,nstages,param,dispersal,init,interactionsD=interact)

### Two species competition (same is better)
nstages <- c(3,2)
init <- list(c(100,0,10),c(100,30))
param <- matrix(c(2,1,0,0, 1,1,0,.1, .5,0,6,1, 1,1,0,.2, .5,0,2,2), byrow=T, nrow=5) 
interact <- matrix(c(0,0,0,0,0, 0,0,0,0,0, 0,0,-.1,0,-.2, 0,0,0,0,0, 0,0,-.2,0,-.1),ncol=5)
results$compet2same <- community(maxt,nstages,param,dispersal,init,interactionsD=interact)

### Two species competition facilitation
nstages <- c(3,2)
init <- list(c(100,0,10),c(100,30))
param <- matrix(c(2,1,0,0, 1,1,0,.1, .5,0,6,1, 1,1,0,.2, .5,0,2,2), byrow=T, nrow=5) 
interact <- matrix(c(0,0,0,0,0, 0,-.1,+.1,-.1,0, 0,0,-.1,0,-.2, 
                                0,-.2,+.2,-.1,0, 0,0,-.2,0,-.1),ncol=5)
results$competfac2 <- community(maxt,nstages,param,dispersal,init,interactionsD=interact)

### Three species competition facilitation
nstages <- c(3,2,1)
init <- list(c(100,0,10),c(100,30),c(20))
param <- matrix(c(2,1,0,0, 1,1,0,.1, .5,0,6,1, 
                  1,1,0,.2, .5,0,2,2, 
                  .1,0,.2,3), byrow=T, nrow=6) 
interact <- matrix(c(0,0,0,0,0,-.1, 0,-.1,+.1,-.1,0,+.1, 0,0,-.1,0,-.2,-.1, 
                                    0,-.2,+.2,-.1,0,+.1, 0,0,-.2,0,-.1,-.1,
                                                         0,0,-.01,0,-.01,-.02),ncol=6)
results$competfac3 <- community(maxt,nstages,param,dispersal,init,interactionsD=interact)

abunds <- lapply(results,abundance.matrix)
