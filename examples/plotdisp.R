library(animation)
#1/(2+1)=1/3
#.2/(.2+1.4)=1/8
#s=1/24
#Rs=.25
#.2/(.2+.2)=1/2
#s=1/6
#Rs=1
numstages <- 3
deathrates <- c(2, 1.4, 0.5)  # death rates for seed, sapling and adult
growthrates <- c(1, 0.2)      # transition rates seed-->sapling and sapling-->adult
reproductionrate <- 6        # reproduction rate (only adult)
initialpop <- c(0,0,200,100)    # initial pop. sizes for the 3 stages plus the facilitator species
facindex <- c(0,1.2)            # this will be the values by which facilitator decreases seeds and seedlings deathrates
effects <- c(0,0,0, 0,-0.5,0, 0,0,-1) # the effects reducing deathrate (negative values increase deathrates)
radius <- c(0,0.2,2,3)        # this are the distances up to which the individuals can have effect on others, by stage + facilitator
h <- 100                       # arena height
w <- 100                       # arena width

maxt <- 500
#deathrates <- deathrates-c(facindex,0)
wrapper <- function(disp){ set.seed(1235)
facByRates(maxt, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=disp, R=reproductionrate, 
	   interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)}

library(parallel)

dispersions <- .2*2^(0:6)
results <- mclapply(dispersions,wrapper)

details=400
times <- seq(10,maxt,length.out=details)         # array of times of interest
	abmatrices <- mclapply(results,function(r){abundance_matrix(r,times)[,1:3]})

	poptots <- lapply(abmatrices,rowSums)
	# PLOT TOGHETER 
	colors <- colorRampPalette(c("red","blue4"))(length(dispersions))

	maxpop = max(sapply(poptots,max))
	plot(NULL,NULL,ylim=c(0,maxpop),xlim=c(min(times),max(times)),ylab="População",xlab="Tempo",main="População total")

	for(i in 1:length(dispersions)){
		x <- poptots[[i]]
		lines(x~times,col=colors[i],lwd=1.2)
	}

	legend("topleft", legend=dispersions, fill=colors)
	savePlot("dispersesumK.png")

	#FIT STUFF
	logisticgrowth <- function(r,K,N0,t){ ((K*N0*exp(r*t))/(K-N0+N0*exp(r*t))) }
	mat <- mat.model(n=numstages,Ds=deathrates-c(facindex,0),Gs=growthrates,R=reproductionrate)
	intr <- limiting.rate(mat) 
	fit.data.log <- function(pop) { tryCatch(nls(pop~logisticgrowth(r,K,N0,times),start=list(r=intr,K=maxpop,N0=80)),error=function(e) NA)}
	fits <- lapply(poptots,fit.data.log)
	for(i in 1:length(dispersions)){
		x <- poptots[[i]]
		if(!is.na(fits[[i]])){
			c <- coef(fits[[i]])
			lines(logisticgrowth(c[1],c[2],c[3],times)~times,col=colors[i],lty=2)
		}
	}
	savePlot("dispersesumKregressed.png")

	sapply(fits,function(f){tryCatch(coef(f),error=function(e){ c(NA,NA,NA) }) })->c
	c
c <- plotandfit(results,times)
round(c,2)

# values for maxt=150
#          [,1]         [,2]         [,3]        [,4]         [,5]
#r   0.09651764   0.09128937    0.0916849    0.135033    0.1515106
#K  96.82088069 778.53839978 3719.3842417 5385.237215 5497.2109551
#N0 79.50164039  70.48521383   77.3500536   90.847668   86.0328551


# values for maxt=150
#          [,1]         [,2]         [,3]         [,4]         [,5]
#r   0.02961239 4.547562e-02 9.612962e-02    0.1341764    0.1589538
#K  90.93559012 1.110404e+03 1.315846e+03 1496.3517842 1521.8805725
#N0 36.37539761 8.951991e+01 6.994567e+01   53.0875249   39.7258234

allgifs<- function(results){
	times <- seq(0,maxt,length.out=80)
	for(i in 1:length(dispersions)){
		saveGIF(spatialplot(results[[i]],times),interval=0.1,movie.name=paste0("disperse",i,".gif")) 
	}
}

#plot(NULL,NULL,xlim=c(-10,10),ylim=c(0,1),xlab="distance",ylab="P(x) > d")
#for(i in c(1,3,5,7)){
#	lambda <- 1/dispersions[i]
#	curve(exp(-lambda*abs(x)),from=-10,to=10,add=T,col=colors[i])
#}
#abline(v=2,lty=2)
#abline(v=-2,lty=2)

