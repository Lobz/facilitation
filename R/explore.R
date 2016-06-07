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

distance <- function(ab,so){
	zeroes <- unique(c(which(ab==0,arr.ind=T)[,1],which(so==0,arr.ind=T)[,1]))
	if(length(zeroes)>0){
		ab <- ab[-zeroes,]
		so <- so[-zeroes,]
	}
	d <- log(ab/so)
	SSQ <- sum(d*d)
	SSQ	
}

fitted.rate <-function(ab.mat){
	regression <- fit.data(ab.mat)
	coef(regression)[2]
}

mat.model.wrapper1.3stages <- function(d1,d3,g1,g2,r.add) {
	re <- array()
	re[1] <- limiting.rate(mat.model(n=3,Ds=c(d1,1,d3),Gs=c(g1,g2),R=r.add+d3))
	re[2] <- limiting.rate(mat.model(n=3,Ds=c(d1,0,d3),Gs=c(g1,g2),R=r.add+d3))
	re[3] <- facilitation.class(re[1],re[2])
	if(re[3]=="mixed") { # facilitation on d2 actually could have an efect!
		d2 <- .5
		sup <- 1
		inf <- 0
		limr <- limiting.rate(mat.model(n=3,Ds=c(d1,d2,d3),Gs=c(g1,g2),R=r.add+d3))
		while(abs(limr) > .0001){
			if(limr>0){
				inf <- d2
			}
			else {
				sup <- d2
			}
			d2 <- (sup+inf)/2
			limr <- limiting.rate(mat.model(n=3,Ds=c(d1,d2,d3),Gs=c(g1,g2),R=r.add+d3))
		}
		re[4] <- d2
	}
	else if(re[3] == "positive"){ #let's go crazy with that deathrate
		d2 <- 2
		limr <- limiting.rate(mat.model(n=3,Ds=c(d1,d2,d3),Gs=c(g1,g2),R=r.add+d3))
		while(limr >0){
			d2 <- d2*2
			limr <- limiting.rate(mat.model(n=3,Ds=c(d1,d2,d3),Gs=c(g1,g2),R=r.add+d3))
		}
		sup <- d2
		inf <- d2/2
		d2 <- (sup+inf)/2
		limr <- limiting.rate(mat.model(n=3,Ds=c(d1,d2,d3),Gs=c(g1,g2),R=r.add+d3))
		while(abs(limr) > .0001){
			if(limr>0){
				inf <- d2
			}
			else {
				sup <- d2
			}
			d2 <- (sup+inf)/2
			limr <- limiting.rate(mat.model(n=3,Ds=c(d1,d2,d3),Gs=c(g1,g2),R=r.add+d3))
		}
		re[4] <- d2
	}
	else{ re[4] <- NA }
	return(re)
}

expgrowthtime <- function(d,g){
	integ <- integrate(f=function(x,d,g){(d*x*exp(-d*x)/(1-exp(-g*x)))},upper=Inf,lower=0,g=g,d=d)
	t <- 1/g +1/d - integ$value
	c(t,integ$abs.error)
}

egt <- function(d,g){expgrowthtime(d,g)[1]}
egtVec <- function(d,g){mapply(egt,d,g)}
mat.model.wrapper <- function(data){
	mapply(mat.model.wrapper1.3stages,data[,1],data[,2],data[,3],data[,4],data[,5])
}

expgrowthrate <- function(d3,alphaR,tildet){W(alphaR*tildet*exp(-d3*tildet))/tildet - d3}
alphaRcalc <- function(d1,d2,g1,g2,R){ (g1/(g1+d1))*(g2/(g2+d2))*R }
tiltetcalc <- function(d1,d2,g1,g2) { egtVec(d1,g1)+egtVec(d2,g2) }
expgrowthrate.full <- function(d1,d2,d3,g1,g2,R){ expgrowthrate(d3,(g1/(g1+d1))*(g2/(g2+d2))*R, egt(d1,g1)+egt(d2,g2)) }

egr.wrapper <- function(dt,d2){mapply(expgrowthrate.full,dt[,1],d2,dt[,2],dt[,3],dt[,4],dt[,5]+dt[,2])}
