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
	if(length(times)>1){
		for(i in 2:length(times)){
			t <- times[i]
			snap <- rbind(snap,cbind(t,res[[i]]))
		}
	}

	snap
}

plotsnapshot <- function(data,t,...) {
	spatialplot(data,c(t),...)
}

facByRates <- function(maxtime, n, Ds, Gs, R, dispersal=1, interactions=rep(0,n*n), fac=rep(0,n-1), init=rep(10,n+1), rad=rep(2,n+1), height=100, width=100, boundary="reflexive", facilitatorD=0,facilitatorR=0,facilitatorC=0, dispKernel="exponential", maxpop=30000){

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
	r <- test_parameter(maxtime,num_stages=n,parameters=c(M),dispersal=dispersal,interactions=N,init=init,h=height,w=width,bcond=boundary,dkernel=disp,maxpop=maxpop)
	
	# prepare output
	N <- matrix(N,nrow=n+1)
	rownames(N) <- 0:n
	colnames(N) <- 0:n
	dt <- list2dataframe.new(r)
	#dt <- list2dataframe(dt)


	list(data = dt,n=n+1, maxtime=maxtime, 
	     stages=n,D=Ds,G=Gs,R=R,radius=rad,dispersal=dispersal,interactions=N,init=init,h=height,w=width,bcond=boundary,dkernel=dispKernel)
}
#dt <- facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)

abundance_matrix <- function(data,times=seq(0,data$maxtime,length.ou=20)){
	n <- data$n
	subs <- lapply(times,function(t){subset(data$data,begintime <= t & (endtime >= t | is.na(endtime)),select=c(1,2))})
	abmatline <- function(x){
		l <- tapply(x$id,x$sp,length)
		# complete the rows that are missing
		if(length(l) == n){
			abl = l
		}
		else {
			abl <- rep(0,n)
			names(abl) <- 0:(n-1)
			for(i in 0:(n-1)){
				if(i %in% names(l)){
					c <- which(names(l)==i)
					abl[i+1] <- l[c]
				}
			}		
		}
		abl
	}
	ab <- t(sapply(subs,abmatline))
	rownames(ab) <- times

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

