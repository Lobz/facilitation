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
#' obj <- facByRates(maxtime=2,n=3,Ds=c(5,1.2,0.1),Gs=c(1,.5),R=10,dispersal=2,init=c(100,0,0,0))
#' times <- seq(0,2,by=0.1)
#' ab <- abundance_matrix(obj,times)
#' stackplot(ab[,1:3])
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

	N <- dim(mat)[2]
	time <- as.numeric(rownames(mat))
	for (i in (N-1):1) # sums populations IN REVERSE, may cause problems for 1 stages only
		mat[,i] = mat[,i] + mat[,i+1]
	mat <- cbind(mat, rep(minp, length(time)))
	# maximo da escala do grafico
	maxp <-max(mat[,1])

	if (! "ylim" %in% names(dots)) dots$ylim = c(minp, maxp)
	if (! "xlim" %in% names(dots)) dots$xlim = c(min(time),max(time))
	if (! "main" %in% names(dots)) dots$main = "Population dynamics"
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

#' function for ploting simulation frames
#'
#' @author Alexandre Adalardo de Oliveira - 16/03/2016
#' @author M. Salles
#' @param data	result of a simulation, created by \code{\link{facByRates}}
#' @param times	array of times at which to plot
#' @param xlim	Optional. Limits to the x-axis
#' @param ylim	Optional. Limits to the y-axis
#' @param col 	Optional. A color vector
#' @param tframe a time length to wait between frames. Do not use if using this with
#' \code{animation}
#' @examples
#' malthusian <- facByRates(maxtime=2,n=3,Ds=c(5,1.2,0.1),Gs=c(1,.5),R=10,dispersal=2,init=c(100,0,0,0),rad=c(0,1,2,0))
#' times <- seq(0,2,by=0.1)
#' # plot
#' spatialplot(malthusian,times,tframe=.1)
#'
#' # make a gif
#' library(animation)
#' saveGIF(spatialplot(malthusian,times),interval=0.1,movie.name="malthusian.gif") 
spatialplot = function(data, times=seq(0,data$maxtime,length.out=20), xlim=c(0,data$w), ylim=c(0,data$h), 
		       col=c(colorRampPalette(c("darkred","pink"))(data$n-1),"lightgreen"),tframe=0)
{
	radius <- data$radius
	# creates list of dataframes, one for each time
	dtlist <- lapply(times,function(t){subset(data$data,begintime <= t & (endtime >= t | is.na(endtime)))})
	maxst <- data$n
	# set minimum radius for stages with rad=0
	for(i in 1:length(radius)) if(radius[i] == 0) radius[i] = 0.05
	# init viewport
	vp <- viewport(width = 0.8, height = 0.8, xscale=xlim, yscale=ylim)
	# loop through times
	for (i in 1:length(times))
	{
		dt = dtlist[[i]]
		if(dim(dt)[1] > 0) {# interrupt if population is zero

			grid.newpage()
			pushViewport(vp)
			grid.rect(gp = gpar(col = "gray"))
			for (j in maxst:1){
				dtsp <- dt[dt$sp==j,]
				if(dim(dtsp)[1] > 0){
					grid.circle(x = dtsp$x, y=dtsp$y, r=radius[j],default.units="native", gp=gpar(fill=col[j],col=col[j]))
				}
			}
			grid.text(paste("t =",round(times[i],digits=4)), y=1.06)
			grid.xaxis(at=round(seq(xlim[1],xlim[2], len=5)))
			grid.yaxis(at=round(seq(ylim[1],ylim[2], len=5)))
			Sys.sleep(tframe)
		}
	}
}

plotsnapshot <- function(data,t,...) {
	spatialplot(data,c(t),...)
}
