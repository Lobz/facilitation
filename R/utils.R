list2dataframe <- function(x) {
	ret<-data.frame(matrix(unlist(x),length(x),byrow=TRUE))
	names(ret)<- c("t", "sp", "id", "x", "y")
	return(ret)
}

plot_all <- function(dt) {
	plot(dt$x~dt$y, type='n',xlab="x",ylab="y");
	for(i in unique(dt$sp)){
		dts<- subset(dt,dt$sp==i);
		points(dts$x,dts$y,pch=i,col=2*i);
	}
}

facByRates <- function(times, n=3, Ds=c(2,rep(1,n-1)), Gs=rep(1,n-1), R=5, fac=0, height=10, width=10,init=rep(10,n+1), rad=2){
	M <- matrix(c(Gs, 0, rep(0, n-1),R,Ds, rep(0, n)), nrow = n)
	M <- rbind(M,c(0,0,0,rad))
	M <- as.vector(t(M))
	r <- test_parameter(times,num_stages=n,parameters=M,f=fac,init=init,h=height,w=width)
	list2dataframe(r)
}

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

