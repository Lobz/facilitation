list2dataframe <- function(x) {
	ret<-data.frame(t(matrix(unlist(x),5)))
	names(ret)<- c("t", "sp", "id", "x", "y")
	return(ret)
}

plot_all <- function(dt,w,h) {
	plot(dt$x~dt$y, type='n',xlab="x",ylab="y",xlim=c(0,w),ylim=c(0,h));
	for(i in unique(dt$sp)){
		dts<- subset(dt,dt$sp==i);
		points(dts$x,dts$y,pch=i,col=i);
	}
}

test_standard <- function(f,t){
	ret <-  (list2dataframe(test_parameter(t,3,c(1.5,0,2,0, 1,0,1,0, 0,2,0.1,0, 0,0,0,1),f,10,10,c(10,10,10,10))));
	ret
}

abundance_matrix <- function(ret){
	return(tapply(ret$id, list(ret$t, ret$sp), length))
}

