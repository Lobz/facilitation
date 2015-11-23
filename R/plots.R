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
#'obj <- test_standard(10, 10)
#'mat <- abundance_matrix(obj)
#'stackplot(mat)
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
  mat <- cbind(mat, rep(0, length(time)))
  # maximo da escala do grafico
  maxp <-max(mat[,1])

  plot(0, type='n', ylim=c(minp, maxp), xlim=c(0, max(time)), ylab="Population", xlab="Time", main="Facilitation dynamics", log=log, ...)
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

