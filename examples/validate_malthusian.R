numstages <- 3
deathrates <- c(2, 0.2, 0.2)  # death rates for seed, sapling and adult
growthrates <- c(1, 0.2)      # transition rates seed-->sapling and sapling-->adult
reproductionrate <- 8        # reproduction rate (only adult)
dispersalradius <- 2          # average distance a seed falls from the parent (distance is gaussian)
t <- 10
initialpop <- c(100,100,100,0)    # initial pop. sizes for the 3 stages plus the facilitator species

results <- facilitation(maxtime=t, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=1,
		 R=reproductionrate, init=initialpop)
times <- seq(0,t,length.out=100)
ab <- abundance.matrix(results,times)[,1:numstages]
mat <- mat.model(n=numstages,Ds=deathrates,Gs=growthrates,R=reproductionrate)
so <- solution.matrix(p0=initialpop[1:numstages], M=mat, times=times)

par(mfrow=c(2,2))
stackplot(ab, main="Dinâmica Populacional")
lines(so[,3]~rownames(so),lty=3)
lines(so[,3]+so[,2]~rownames(so),lty=3)
lines(so[,3]+so[,2]+so[,1]~rownames(so),lty=3)

stackplot(ab, log.y=T, main="Dinâmica Populacional (escala log)")
lines(so[,3]~rownames(so),lty=3)
lines(so[,3]+so[,2]~rownames(so),lty=3)
lines(so[,3]+so[,2]+so[,1]~rownames(so),lty=3)

props<- ab/rowSums(ab)
sop<- so/rowSums(so)
stackplot(props,main="Proporção Etária")
lines(sop[,3]~rownames(sop),lty=3)
lines(sop[,3]+sop[,2]~rownames(sop),lty=3)

ab1<-ab[1:99,]
ab2<-ab[2:100,]
taxas<- ((ab2-ab1)/(times[2:100]-times[1:99]))/ab1
plot(taxas[,1]~times[1:99],type="l",main="Taxa de Crescimento",xlab="Time",ylab="Rate")
lines(taxas[,2]~times[1:99])
lines(taxas[,3]~times[1:99])
so1<-so[1:99,]
so2<-so[2:100,]
taxas<- ((so2-so1)/(times[2:100]-times[1:99]))/so1
lines(taxas[,1]~times[1:99],lty=3)
lines(taxas[,2]~times[1:99],lty=3)
lines(taxas[,3]~times[1:99],lty=3)
abline(h=(limiting.rate(mat)),lty=3,col=2)

