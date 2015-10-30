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

test_standard <- function(t){
	data <- test_parameter(t,3,c(1.5,0,2,0, 1,0,1,0, 0,10,0.5,0, 0,0,0,1),1,10,10,c(10,10,10,1))
	list2dataframe(data);
}

abundance_matrix <- function(ret){
	m <- (tapply(ret$id, list(ret$t, ret$sp), length))
	m[is.na(m)]<-0
	m
}

