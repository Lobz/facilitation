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
	dots <- list(...)
	if(missing(col))
		#col <- terrain.colors(dim(mat)[2])
		col <- colorRampPalette(c("darkred","pink"))(dim(mat)[2])
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

	if (! "ylim" %in% names(dots)) dots$ylim = c(minp, maxp)
	if (! "xlim" %in% names(dots)) dots$xlim = c(min(time),max(time))
	if (! "main" %in% names(dots)) dots$main = "Facilitation dynamics"
	if (! "ylab" %in% names(dots)) dots$ylab = "Population"
	if (! "xlab" %in% names(dots)) dots$xlab = "Time"

	do.call(plot, c(list(1, type='n', log=log), dots))
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
	legend("topleft", legend=legend, fill=col, bg="white")
}

##############################################################
# function for ploting simulation frames for facilita package
# Alexandre Adalardo de Oliveira - 16/03/2016
##############################################################
spatialplot = function(data, times=data$expected.times, xlim=c(min(data$data$x),max(data$data$x)), ylim=c(min(data$data$y),max(data$data$y)), cor=c(colorRampPalette(c("darkred","pink"))(data$n-1),"lightgreen"),tframe=0)
{
	#library(grid)
	dt <- snapshotdataframe(data$data,times)
	radius <- data$radius
	seqt <- unique(dt$t)
	maxst <- max(dt$sp)
	for(i in 1:length(radius)) if(radius[i] == 0) radius[i] = 0.05
	vp <- viewport(width = 0.8, height = 0.8, xscale=xlim, yscale=ylim)
	for (i in seqt)
	{
		dt0=dt[dt$t==i,]
		grid.newpage()
		pushViewport(vp)
		grid.rect(gp = gpar(col = "gray"))
		for (j in maxst:0){
			dtsp <- dt0[dt0$sp==j,]
			if(dim(dtsp)[1] > 0){
				grid.circle(x = dtsp$x, y=dtsp$y, r=radius[j+1],default.units="native", gp=gpar(fill=cor[j+1],col=cor[j+1]))
			}
		}
		grid.text(paste("t =",round(i,digits=4)), y=1.06)
		grid.xaxis(at=round(seq(xlim[1],xlim[2], len=5)))
		grid.yaxis(at=round(seq(ylim[1],ylim[2], len=5)))
		Sys.sleep(tframe)    
	}
}
#####################
#spatialplot(data=dt)
