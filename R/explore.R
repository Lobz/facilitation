limiting.rate <- function(mat){max(Re(eigen(mat)$values))}

eigen.profile <- function(mat){
	e <- eigen(mat)$values
	I <- Im(e)
	R <- Re(e)
	indc <- which(I!=0)
	indr <- which(I==0)
	if(length(indc)==0)		{return(1)} # ALL REAL
	else{ # non-real eigenvalues
		if(length(indr) == 0)	{return(2)} # ALL NON-REAL
		c <- max(R[indc])
		r <- max(R[indr])
		if(c < 0)		{return(3)} # NON-REAL ALL NEGATIVE
		else if(c < r)		{return(4)} # DOMINANT EIGENVALUE IS REAL
		else			{return(5)} # BIGGER EIGENVALUE IS NON-REAL !!!
	}
}

facilitation.class <- function(lim.wo,lim.wi){
	if(lim.wo > 0) {return("positive")} # both positive
	if(lim.wi > 0) {return("mixed")} # mixed
	else{return("negative")} # both negative
}

facilitation.class.wrapper <- function(data){
	lim <- mat.model.wrapper(data)
	lim.wo <- lim[1,]
	lim.wi <- lim[2,]
	mapply(facilitation.class,lim.wo,lim.wi)
}

fitted.rate <- function(ab.mat){
	total <- data.frame(rowSums(ab.mat))
	total$times <- as.numeric(rownames(ab.mat))
	names(total) <- c("y","x")
	regression <- nls(y ~intersect * exp(slope * x), data=total, start=list(intersect=1,slope=1))
	coef(regression)[2]
}

solveandfit.rate <- function(mat){
	so <- solution.matrix(rep(1,nrow(mat)),mat,seq(1,30,0.05))
	fitted.rate(so)
}

mat.model.wrapper1.3stages <- function(d1,d2,d3,g1,g2,r.add,f) {
	re <- array()
	re[1] <- limiting.rate(mat.model(n=3,Ds=c(d1,d2,d3),Gs=c(g1,g2),R=r.add+d3))
	re[2] <- limiting.rate(mat.model(n=3,Ds=c(d1-f,d2,d3),Gs=c(g1,g2),R=r.add+d3))
	return(re)
}

mat.model.wrapper <- function(data){
	mapply(mat.model.wrapper1.3stages,data[,1],data[,2],data[,3],data[,4],data[,5],data[,6],data[,7])
}
