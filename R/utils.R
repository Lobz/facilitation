list2dataframe <- function(x) {data.frame(t(matrix(unlist(x),5)))}

plot_all <- function(dt,w,h) {
	plot(dt$X4~dt$X5, type='n',xlab="x",ylab="y",xlim=c(0,w),ylim=c(0,h));
	for(i in unique(dt$X2)){
		dts<- subset(dt,dt$X2==i);
		points(dts$X4,dts$X5,pch=i);
	}
}

