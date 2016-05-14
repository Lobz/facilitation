#' Plots 
#' 
#' Plotting functions.
#' 
#' The \code{stackplot} function produces a stacked plot of the population over time.
#' Notice that the population should have at least two stages for this function to work.
#' 
#' @param mat A population matrix, as produced by \code{\link{abundance_matrix}}
#' @param col Optional. A color vector
#' @param legend Optional. An array of names
#' @param log.y Logical. Should the y-axis be plotted in a logarithmic scale?
#' @param \dots Further parameters to be passed to the lower level plot function
#' @examples
#' obj <- facByRates(times=0:10)
#' mat <- abundance_matrix(obj)
#' stackplot(mat)
stackplot <- function(mat, col, legend, log.y = FALSE, ...) {
	if(missing(col))
		col <- terrain.colors(dim(mat)[2])
	if (log.y) {
		minp <- 1
		log <- "y"
	} else {
		minp <- 0
		log <- ""
	}

	# If extinct, removes last spurious line
	if (is.nan(rownames(mat)[dim(mat)[1]]))
		mat <- mat[-dim(mat)[1],]
	N <- dim(mat)[2]
	time <- as.numeric(rownames(mat))
	for (i in (N-1):1) # sums populations IN REVERSE, may cause problems for 1 stages only
		mat[,i] = mat[,i] + mat[,i+1]
	mat <- cbind(mat, rep(minp, length(time)))
	# maximo da escala do grafico
	maxp <-max(mat[,1])

	plot(1, type='n', ylim=c(minp, maxp), xlim=c(0, max(time)), ylab="Population", xlab="Time", main="Facilitation dynamics", log=log, ...)
	x <- c(time, rev(time))
	for (i in 1:(N)) {
		y <- c(mat[,i], rev(mat[,i+1]))
		polygon(x,y, col=col[i])
	}
	if (missing(legend)) { 
		if(N == 2) legend <- c("Juveniles", "Adults")
		if(N == 3) legend <- c("Seeds", "Juveniles", "Adults")
		if(N > 3) legend <- c(1:N)
	}
	legend("topleft", legend=legend, fill=col)
}

##############################################################
# function for ploting simulation frames for facilita package
# Alexandre Adalardo de Oliveira - 16/03/2016
##############################################################
spatialplot = function(data,radius, xlim=c(min(dt$x),max(dt$x)), ylim=c(min(dt$y),max(dt$y)), cor=c("lightgreen","blue", "red","pink"),tframe=0)
{
	#library(grid)
	seqt <- unique(dt$t)
	numst <- max(data$sp)
	for(i in 1:length(radius)) if(radius[i] == 0) radius[i] = 0.05
	dt0=data[data$t==seqt[1],]
	vp <- viewport(width = 0.8, height = 0.8, xscale=xlim, yscale=ylim)
	pushViewport(vp)
	grid.rect(gp = gpar(col = "gray"))
	grid.xaxis(at=round(seq(xlim[1],xlim[2], len=5)))
	grid.yaxis(at=round(seq(ylim[1],ylim[2], len=5)))
	if(length(dt0$sp[dt0$sp==3])>0) {
		plotfac <- T
		raiofacilita<-grid.circle(x=dt0$x[dt0$sp==3],y=dt0$y[dt0$sp==3], r=radius[4] ,default.units="native", gp=gpar(fill=cor[1], col="gray"))
	}
	for (j in numst:1){
		if(length(dt0$sp[dt0$sp==j-1])>0){
			grid.circle(x = dt0$x[dt0$sp==j-1], y=dt0$y[dt0$sp==j-1], r=radius[j],default.units="native", gp=gpar(fill=cor[j+1],col=cor[j+1]))
		}
	}
	for (i in seqt[-1])
	{
		dt0=dt[dt$t==i,]
		grid.newpage()
		pushViewport(vp)
		grid.text(paste("t =",round(i,digits=4)), y=1.06)
		grid.rect(gp = gpar(col = "gray"))
		grid.xaxis(at=round(seq(xlim[1],xlim[2], len=5)))
		grid.yaxis(at=round(seq(ylim[1],ylim[2], len=5)))
		if(plotfac) grid.draw(raiofacilita)
		for (j in numst:1){
			if(length(dt0$sp[dt0$sp==j-1])>0){
				grid.circle(x = dt0$x[dt0$sp==j-1], y=dt0$y[dt0$sp==j-1], r=radius[j],default.units="native", gp=gpar(fill=cor[j+1],col=cor[j+1]))
			}
		}
		Sys.sleep(tframe)    
	}
}
#####################
#spatialplot(data=dt,radius=c(0,0,1,2))
