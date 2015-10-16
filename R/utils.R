fist2dataframe <- function(x) {data.frame(t(matrix(unlist(x),5)))}

plot_all <- function(dt,w,h) {
	plot(dt$X4~dt$X5, type='n',xlab="x",ylab="y",xlim=c(0,w),ylim=c(0,h));
	for(i in unique(dt$X2)){
		dts<- subset(dt,dt$X2==i);
		points(dts$X4,dts$X5,pch=i);
	}
}

pertime <- function(ret, sp){
	times <- unique(ret$X1);
	t  <- length(times)
	sm <- array();
	r <- subset(ret,ret$X2==sp);
	for(i in 1:t){
		sm[i] <- sum(r$X1 == times[i]);
	}
	return (sm);
}

test_standard <- function(f,t){
	return (list2dataframe(test_parameter(t,3,c(1,0,0.3,0, 1,0,1,0, 0,2,0.1,0, 0,0,0,1),f,10,10,c(10,10,10,10))));
}

plottimes <- function(ret){
	times <- unique(ret$X1);
	pt <- pertime(ret,0)+pertime(ret,1)+pertime(ret,2)
	plot(pt~times, col=1, ylim=c(0,max(pt)), type='l')
	lines(pertime(ret,0)~times, col=2)
	lines(pertime(ret,1)~times, col=3)
	lines(pertime(ret,2)~times, col=4)
}

