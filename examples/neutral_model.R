
maxt<-60
dispersal<-30

### Four species two stages competition 
nsp <- 100
nst <- 2
init <- c(20,20)
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

neutral <- community(maxt,nstages,param,dispersal,init,interactions=interact,h=50,w=50,maxpop=300000)

neutral$radius <- rep(c(.2,.4),nsp)
a<-abundance.matrix(neutral)
stackplot(a)
last<- c(abundance.matrix(neutral,neutral$maxtime)[,(1:nsp)*nst])
plot(sort(last))
plotsnapshot(neutral,neutral$maxtime)

adusapfac <- +.1
intersap <- c(rep(c(sapsap,adusap),nsp/2),rep(c(sapsap,adusapfac),nsp/2)) # half of the species are facilitators, all saplings receive facilitation
interact <- matrix(c(rep(c(intersap,interadu),nsp)),ncol=totstages)


facil <- community(maxt,nstages,param,dispersal,init,interactions=interact,h=50,w=50,maxpop=300000)
a<-abundance.matrix(facil)
stackplot(a)
