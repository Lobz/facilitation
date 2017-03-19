load_all()
library(pse)
comparison <- function(Ds,Gs,R,init,fac,disp,maxt,c2,c3) {
	rad <- c(0,.2,2,3)
	malthusian <- facByRates(maxt,n=3,Ds=Ds,Gs=Gs,R=R,init=c(init),dispersal=disp,rad=rad)
	facilitated <- facByRates(maxt,n=3,Ds=Ds,Gs=Gs,R=R,fac=c(0,fac),init=c(init),dispersal=disp,rad=rad)
	logistic <- facByRates(16*maxt,n=3,Ds=Ds,Gs=Gs,R=R,init=c(init),dispersal=disp,interactions=c(0,0,0,0,-c2,0,0,0,-c3),rad=rad)
	complete <- facByRates(16*maxt,n=3,Ds=Ds,Gs=Gs,R=R,fac=c(0,fac),init=c(init),dispersal=disp,interactions=c(0,0,0,0,-c2,0,0,0,-c3),rad=rad)

	mat <- mat.model(n=3,Ds=Ds,Gs=Gs,R=R)
	times <- seq(0,maxt,length.out=100)
	so <- solution.matrix(init[1:3],mat,times)
	ab.m <- abundance_matrix(malthusian,times)[,1:3]
	ab.f <- abundance_matrix(facilitated,times)[,1:3]
	ab.l <- abundance_matrix(logistic,16*times)[,1:3]
	ab.c <- abundance_matrix(complete,16*times)[,1:3]

	save(malthusian,facilitated,logistic,complete,mat,times,so,ab.m,ab.f,ab.l,ab.c,file="run.RData")

	re <- array()
	# resutados determinísticos
	re[1] <- limiting.rate(mat)
	re[2] <- fitted.rate(so)
	re[3] <- tryCatch(max(coef(fit.data2(so,mat))[c(2,4)]),error=function(e) NA)
	re[4] <- expgrowthrate.full(Ds[1],Ds[2],Ds[3],Gs[1],Gs[2],R)

	# resultados simulacionais
	d <- log(ab.m) - log(so)
	d <- d*d
	re[5] <- sum(d)/length(times)

	re[6] <- fitted.rate(ab.m)
	re[7] <- fitted.rate(ab.f)
	re[8] <- fitted.rate(ab.l)
	re[9] <- fitted.rate(ab.c)

	re[10] <- tryCatch(max(coef(fit.data2(ab.m,mat))[c(2,4)]),error=function(e) NA)
	re[11] <- tryCatch(max(coef(fit.data2(ab.f,mat))[c(2,4)]),error=function(e) NA)

	logisticgrowth <- function(r,K,N0,t){ ((K*N0*exp(r*t))/(K-N0+N0*exp(r*t))) }
	fit.data.log <- function(pop) { tryCatch(nls(pop~logisticgrowth(r,K,N0,times),start=list(r=intr,K=maxpop,N0=80)),error=function(e) NA)}
	reglog <- tryCatch(coef(fit.data.log(rowSums(ab.l))),error=function(e){ c(NA,NA,NA) }) 
	re[12] <- reglog[1]
	re[13] <- reglog[2]
	reglog <- tryCatch(coef(fit.data.log(rowSums(ab.c))),error=function(e){ c(NA,NA,NA) }) 
	re[14] <- reglog[1]
	re[15] <- reglog[2]

	return(re)
}

compmalth <- function(d1,d2,d3,g1,g2,R,maxt){

	Ds=c(d1,d2,d3)
	Gs=c(g1,g2)

	mat <- mat.model(n=3,Ds=Ds,Gs=Gs,R=R)
	e <- eigen(mat)$values
	dom.eigenvalue <- max(Re(e))
	dom.eigenvector <- Re(eigen(mat)$vectors[,which(Re(e)==dom.eigenvalue)])
	dom.eigenvector <- dom.eigenvector/sum(dom.eigenvector)

	init <- round(500*dom.eigenvector)

	malthusian <- facByRates(maxt,n=3,Ds=Ds,Gs=Gs,R=R,init=c(init,0),dispersal=0)

	mat <- mat.model(n=3,Ds=Ds,Gs=Gs,R=R)
	times <- seq(0,maxt,length.out=100)
	so <- solution.matrix(init[1:3],mat,times)
	ab.m <- abundance_matrix(malthusian,times)[,1:3]
	save(malthusian,mat,times,so,ab.m,file="run.RData")

	re <- array()
	re[1] <- limiting.rate(mat)
	re[2] <- fitted.rate(so)
	re[3] <- tryCatch(max(coef(fit.data2(so,mat))[c(2,4)]),error=function(e) NA)
	re[4] <- expgrowthrate.full(Ds[1],Ds[2],Ds[3],Gs[1],Gs[2],R)
	# resultados simulacionais
	d <- log(ab.m/so)
	d <- d*d
	re[5] <- sum(d)/length(times)

	re[6] <- fitted.rate(ab.m)
	return(re)
}

comparison.wrapper <- function(d1,d2,d3,g1,g2,R,n1,n2,n3,nf,f,c2,c3,disp,maxt){
	Ds=c(d1,d2,d3)
	Gs=c(g1,g2)
	init <- c(n1,n2,n3,nf)
	comparison(Ds,Gs,R,init,f,disp,maxt,c2,c3)
}

wrapper <- function(data,i,maxt){
	compmalth(data[i,1],data[i,2],data[i,3],data[i,4],data[i,5],data[i,6],maxt)
}

