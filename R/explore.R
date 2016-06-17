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

fit.data <- function(ab.mat){
	y <- log(rowSums(ab.mat))
	x <- as.numeric(rownames(ab.mat))
	regression <- lm(y~x)
	regression
}

fit.data2 <- function(ab.mat,mat){
	total <- data.frame(rowSums(ab.mat))
	total$times <- as.numeric(rownames(ab.mat))
	names(total) <- c("y","x")

	e <- sort(Re(eigen(mat)$values))
	regression <- nls(y ~exp(intersect1+slope1 * x) + exp(intersect2+slope2 * x), data=total, 
			  start=list(intersect1=1,slope1=e[3],intersect2=1,slope2=e[2]))
	regression
}

fitted.rate <-function(ab.mat){
	regression <- fit.data(ab.mat)
	coef(regression)[2]
}

expgrowthtime <- function(d,g){
	integ <- integrate(f=function(x,d,g){(d*x*exp(-d*x)/(1-exp(-g*x)))},upper=Inf,lower=0,g=g,d=d)
	t <- 1/g +1/d - integ$value
	c(t,integ$abs.error)
}

egt <- function(d,g){expgrowthtime(d,g)[1]}
egtVec <- function(d,g){mapply(egt,d,g)}

expgrowthrate <- function(d3,sR,tildet){
	library(LambertW)
	W(sR*tildet*exp(-d3*tildet))/tildet - d3
}
sRcalc <- function(d1,d2,g1,g2,R){ (g1/(g1+d1))*(g2/(g2+d2))*R }
tiltetcalc <- function(d1,d2,g1,g2) { egtVec(d1,g1)+egtVec(d2,g2) }
expgrowthrate.full <- function(d1,d2,d3,g1,g2,R){ expgrowthrate(d3,(g1/(g1+d1))*(g2/(g2+d2))*R, egt(d1,g1)+egt(d2,g2)) }

