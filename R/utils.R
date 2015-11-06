list2dataframe <- function(x) {
	ret<-data.frame(matrix(unlist(x),length(x),byrow=TRUE))
	names(ret)<- c("t", "sp", "id", "x", "y")
	return(ret)
}

plot_all <- function(dt) {
	plot(dt$x~dt$y, type='n',xlab="x",ylab="y");
	for(i in unique(dt$sp)){
		dts<- subset(dt,dt$sp==i);
		points(dts$x,dts$y,pch=i,col=i);
	}
}

test_standard <- function(){
	data <- test_parameter(seq(0,3,0.15),3,c(1.5,0,2,0, 1,0,1,0, 0,10,0.5,0, 0,0,0,1),1,c(10,10,10,10))
	list2dataframe(data);
}

facByRates <- function(times, n=3, Ds=c(2,rep(1,n-1)), Gs=rep(1,n-1), R=5, fac=0, height=10, width=10,init=rep(10,n+1)){
	M <- matrix(c(Gs, 0, rep(R, n),Ds, rep(0, n)), nrow = n)
	M <- rbind(M,c(0,0,0,1))
	M <- as.vector(t(M))
	test_parameter(times,num_stages=n,parameters=M,f=fac,init=init,h=height,w=width)
}

abundance_matrix <- function(ret){
	m <- (tapply(ret$id, list(ret$t, ret$sp), length))
	m[is.na(m)]<-0
	m
}

fillTime  <- function(ab,times){
	tm <- rownames(ab)
	tmm <- sort(c(times,tm))
	m <- matrix(nrow=length(tmm),ncol=ncol(ab))
	rownames(m) <- tmm
	colnames(m) <- colnames(ab)
	for(i in 1:length(tmm)){
		for(j in length(tm):1){
			if(rownames(m)[i] <= rownames(ab)[j]) m[i,]<-ab[j,]
		}
	}
	m
}

