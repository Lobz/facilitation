list2dataframe <- function(x) {
	ret<-data.frame(matrix(unlist(x),length(x),byrow=TRUE))
#	n <- (length(ret)-5)/2-1
	names(ret)<- c("t", "sp", "id", "x", "y")#,paste0("a",0:n),paste0("s",0:n))
	return(ret)
}

list2dataframe.new <- function(x) {
	lapply(x,function(d){d[1:6]}) -> base
	dt <- list2dataframe(base) 
	names(dt)<- c("sp", "id", "x", "y","begintime","endtime")
	dt[dt==-1]=NA
	dt
}

snapshotdataframe <- function(x,times) {
	lapply(times,function(t){subset(x,begintime <= t & (endtime >= t | is.na(endtime)))}) -> res
	t <- times[1]
	snap <- cbind(t,res[[1]])
	for(i in 2:length(times)){
		t <- times[i]
		snap <- rbind(snap,cbind(t,res[[i]]))
	}

	snap
}

plot_all <- function(dt) {
	plot(dt$x~dt$y, type='n',xlab="x",ylab="y");
	for(i in unique(dt$sp)){
		dts<- subset(dt,dt$sp==i);
		points(dts$x,dts$y,pch=i,col=2*i);
	}
}

facByRates <- function(times, n, Ds, Gs, R, dispersal=1, interactions=rep(0,n*n), fac=rep(0,n-1), init=rep(10,n+1), rad=rep(2,n+1), height=100, width=100, boundary="reflexive", facilitatorD=0,facilitatorR=0,facilitatorC=0, dispKernel="exponential"){

	# generate parameters for test_parameters
	if(length(rad)==1) rad <- c(rep(0,n),rad)
	M <- t(matrix(c(Gs, 0, 0, rep(0, n-1),R,facilitatorR, Ds,facilitatorD, rad), nrow = n+1))
	N <- matrix(interactions,nrow=n)
	N <- rbind(N,c(fac,0))
	N <- c(N,rep(0,n),-facilitatorC)

	if(dispKernel=="random") disp=0
	else if(dispKernel=="exponential") disp=1
	else {
		"dispKernel not understood"
		return(NULL)
	}
	
	if(boundary=="reflexive") boundary=1
	else if(boundary=="absortive") boundary=0
	else if(boundary=="periodic") boundary=2
	else {
		"boundary not understood"
		return(NULL)
	}
	

	# run simultation
	dt <- test_parameter(times,num_stages=n,parameters=c(M),dispersal=dispersal,interactions=N,init=init,h=height,w=width,bcond=boundary,dkernel=disp)
	
	# prepare output
	N <- matrix(N,nrow=n+1)
	rownames(N) <- 0:n
	colnames(N) <- 0:n
	dt <- list2dataframe.new(dt)
	#dt <- list2dataframe(dt)


	list(data = dt,n=n+1, expected.times = times, #actual.times = unique(dt$t), 
	     stages=n,D=Ds,G=Gs,R=R,radius=rad,dispersal=dispersal,interactions=N,init=init,h=height,w=width,bcond=boundary,dkernel=dispKernel)
}
#dt <- facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)

abundance_matrix <- function(data,times=data$expected.times){
	n <- data$n
	ret <- snapshotdataframe(data$data,times)
	m <- (tapply(ret$id, list(ret$t, ret$sp), length))
	m[is.na(m)]<-0
	if(dim(m)[2] == n){
		ab <- m
	}
	else {
		ab <- matrix(rep(0,length(times)*n),ncol=n,dimnames=list(times,0:(n-1)))
		for(i in 0:(n-1)){
			if(i %in% colnames(m)){
				c <- which(colnames(m)==i)
				ab[,i+1] <- m[,c]
			}
		}		
	}
	ab
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

