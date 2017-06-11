myglm <- function(ab){glm(ab[,1]+ab[,2]+ab[,3]~as.numeric(rownames(ab)),family="poisson")}

panel.cor <- function(x, y, digits = 2, prefix = "", cex.cor, ...)
{
	usr <- par("usr"); on.exit(par(usr))
	par(usr = c(0, 1, 0, 1))
	r <- abs(cor(x, y))
	txt <- format(c(r, 0.123456789), digits = digits)[1]
	txt <- paste0(prefix, txt)
	if(missing(cex.cor)) cex.cor <- 0.8/strwidth(txt)
	text(0.5, 0.5, txt, cex = cex.cor * r)
}

panel.hist <- function(x, ...)
{
	usr <- par("usr"); on.exit(par(usr))
	par(usr = c(usr[1:2], 0, 1.5) )
	h <- hist(x, plot = FALSE)
	breaks <- h$breaks; nB <- length(breaks)
	y <- h$counts; y <- y/max(y)
	rect(breaks[-nB], 0, breaks[-1], y, col = "cyan", ...)
}



explore <- function(n){
	results <- data.frame()
	for(i in 1:n){
		numstages <- 3
		deathrates <- runif(numstages,0,10)
		growthrates <- runif(numstages-1,0,10)
		reproductionrate <- runif(1,0,100)
		maxtime <- 2+800.0/max(10,(sum(growthrates)+sum(deathrates)+10*reproductionrate))
		times <- seq(1,maxtime,maxtime/30)
		initialpop <- c(50,10,10,10)
		facindex <- runif(1,0,deathrates[1])
		radius <- runif(1,0.5,10)

		inputvariables <- c(deathrates,growthrates,reproductionrate,maxtime,facindex,radius)

		#ret <- facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, R=reproductionrate, fac=facindex, init=initialpop, rad=radius)
		#dt <- list2dataframe(ret)
		#ab <- abundance_matrix(dt)
		#g.ibm <- myglm(so)

		mat <- mat_model(n=numstages,Ds=deathrates,Gs=growthrates,R=reproductionrate)
		so <- floor(solution.matrix(p0=initialpop[1:numstages], M=mat, times=times))
		g.mat0 <- myglm(so)

		deathrates2 <- deathrates - c(facindex,rep(0,numstages-1))
		mat <- mat_model(n=numstages,Ds=deathrates2,Gs=growthrates,R=reproductionrate)
		so <- floor(solution.matrix(p0=initialpop[1:numstages], M=mat, times=times))
		g.mat1 <- myglm(so)

		responsevariables <- c(coef(g.mat0),g.mat0$converged,coef(g.mat1),g.mat1$converged)

		results <- rbind(results,c(inputvariables,responsevariables))
	}
	colnames(results) <- c("d1","d2","d3","g1","g2","R","maxtime","facindex","radius","intercept.mat0","slope.mat0","converged.mat0","intercept.mat1","slope.mat1","converged.mat1")
	results
}
 #pairs(results[,-7], lower.panel=panel.smooth, upper.panel=panel.cor, diag.panel=panel.hist)

oneRun <- function(d1,d2,d3,g1,g2,reproductionrate,facindex,radius,facpop){
	numstages<-3
	maxtime <- 5
	deathrates<-c(d1,d2,d3)
	growthrates<-c(g1,g2)
	times <- seq(1,maxtime,maxtime/30)
	initialpop <- c(50,10,10,facpop)
	facindex <- facindex*d1

	#ret <- facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, R=reproductionrate, fac=facindex, init=initialpop, rad=radius)
	#dt <- list2dataframe(ret)
	#ab <- abundance_matrix(dt)
	#g.ibm <- myglm(ab)

	mat <- mat_model(n=numstages,Ds=deathrates,Gs=growthrates,R=reproductionrate)
	so <- floor(solution.matrix(p0=initialpop[1:numstages], M=mat, times=times))
	g.mat0 <- myglm(so)

	deathrates2 <- deathrates - c(facindex,rep(0,numstages-1))
	mat <- mat_model(n=numstages,Ds=deathrates2,Gs=growthrates,R=reproductionrate)
	so <- floor(solution.matrix(p0=initialpop[1:numstages], M=mat, times=times))
	g.mat1 <- myglm(so)

	s0 <- coef(g.mat0)[2]
	s1 <- coef(g.mat1)[2]
	responsevariables <- c(s0,s1,s1-s0,s1*s0 > 0)
	responsevariables
}

modelRun <- function (my.data){
	return(mapply(oneRun, my.data[,1], my.data[,2], my.data[,3], my.data[,4], my.data[,5], my.data[,6], my.data[,7], 0, 10))
}

explore.pse <- function(){
	factors <- c("d1","d2","d3","g1","g2","R","facindex")
	q <- c("qunif")
	q.arg <- list( list(min=0, max=10), list(min=0, max=1), list(min=0, max=1), list(min=0, max=1), list(min=0, max=1), list(min=0, max=10), list(min=0,max=1)) 
	res.names <- c("without facilitation","with facilitation","difference","sign")
	LHS(modelRun, factors, 100, q, q.arg, res.names, nboot=50)
}

# explore.pse() -> myLHS
# plotscatter(myLHS,  add.lm=FALSE)

