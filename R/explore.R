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

explore.pse.3stages <- function(){
	factors <- c("d1","d2","d3","g1","g2","R")
	q <- c(rep("qunif",6))
	# prioris for the six parameters
	q.arg <- list(list(min=0.00001,max=2),list(min=0.00001,max=2),list(min=0,max=0.0002),list(min=0.01,max=0.1),list(min=1.0/600,max=1.0/200),list(min=0.0001,max=10))

	LHS(mat.model.wrapper,factors,200,q,q.arg,nboot=100)
}

mat.model.wrapper1.3stages <- function(d1,d2,d3,g1,g2,r) {
	limiting.rate(mat.model(n=3,Ds=c(d1,d2,d3),Gs=c(g1,g2),R=r))
}

mat.model.wrapper <- function(data){
	mapply(mat.model.wrapper1.3stages,data[,1],data[,2],data[,3],data[,4],data[,5],data[,6])
}
