list2dataframe <- function(x) {
	ret<-data.frame(matrix(unlist(x),length(x),byrow=TRUE))
	n <- (length(ret)-5)/2-1
	names(ret)<- c(c("t", "sp", "id", "x", "y"),paste0("a",0:n),paste0("s",0:n))
	return(ret)
}

plot_all <- function(dt) {
	plot(dt$x~dt$y, type='n',xlab="x",ylab="y");
	for(i in unique(dt$sp)){
		dts<- subset(dt,dt$sp==i);
		points(dts$x,dts$y,pch=i,col=2*i);
	}
}

facByRates <- function(times, n, Ds, Gs, R, dispersal=1, interactions=rep(0,n*n), fac=rep(0,n-2), init=rep(10,n+1), rad=rep(2,n+1), height=100, width=100, boundary=1){

	# generate parameters for test_parameters
	if(length(rad)==1) rad <- c(rep(0,n),rad)
	M <- t(matrix(c(Gs, 0, 0,rep(0, n-1),R,0,Ds,0, rad), nrow = n+1))
	N <- matrix(interactions,nrow=n)
	N <- rbind(N,c(fac,0))
	N <- c(N,rep(0,n+1))

	# run simultation
	r <- test_parameter(times,num_stages=n,parameters=c(M),dispersal=dispersal,interactions=N,init=init,h=height,w=width,bcond=boundary)
	
	# prepare output
	N <- matrix(N,nrow=n+1)
	rownames(N) <- 0:n
	colnames(N) <- 0:n
	dt <- list2dataframe(r)


	list(data = dt, times = times, stages=n,D=Ds,G=Gs,R=R,radius=rad,dispersal=dispersal,interactions=N,init=init,h=height,w=width,bcond=boundary)
}
#dt <- facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)

abundance_matrix <- function(ret){
	m <- (tapply(ret$id, list(ret$t, ret$sp), length))
	m[is.na(m)]<-0
	m
}

fillTime  <- function(ab,times){
	tm <- as.numeric(rownames(ab))
	tmm <- sort(as.numeric(c(times,tm)))
	m <- matrix(nrow=length(tmm),ncol=ncol(ab))
	rownames(m) <- tmm
	colnames(m) <- colnames(ab)
	i <- 1
	for(j in 2:length(tm)){
		while(tmm[i] < tm[j]){
			m[i,] <- ab[j-1,]
			i <- i+1
		}
		m[i,] <- ab[j-1,]
	}
	m[i,] <- ab[j,]
	m
}

