### simplest example
### parameter are D G R
rates <- matrix(c(1,0,2,0),nrow=1) # parameters must be in a matrix
results1 <- community(maxtime=5,numstages=1,parameters=rates,dispersal=10,init=40)


## with maxstresseffect
rates <- matrix(c(0,0,2,0,4),nrow=1) # death rate varies from 0 to 4
results2 <- community(maxtime=5,numstages=1,parameters=rates,dispersal=10,init=40)

## with competition
rates <- matrix(c(0,0,2,1,4),nrow=1) # added radius so that interaction is possible
results3 <- community(maxtime=10,numstages=1,parameters=rates,dispersal=10,init=40,interactionsD=-2)

## two stages
rates <- matrix(c(0,1,0,1,4, 1,0,3,2,0),nrow=2,byrow=T) 
results4 <- community(maxtime=50,numstages=2,parameters=rates,dispersal=10,init=c(40,0),interactionsD=matrix(c(-2,0,0,0),2))

## three stages
rates <- matrix(c(0,1,0,.7,4, 1,1,0,1.2,0, 1,0,6,2,0),nrow=3,byrow=T) # maximum stress effect is 4 for stage 1 and 0 for stages 2 and 3
results5 <- community(maxtime=40,numstages=3,parameters=rates,dispersal=10,init=c(40,0,0),
                      interactionsD=matrix(c(-2,0,0, 0,0,0, 0,0,0),3)) # competition is only between seedlings




