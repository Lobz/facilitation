#' Plots 
#' 
#' The \code{stackplot} function produces a stacked plot of the population over time.
#' @param mat A population matrix, as produced by \code{\link{abundance_matrix}}
#' @param col Optional. A color vector
#' @param legend Optional. An array of names
#' @param \dots Further parameters to be passed to the lower leve plot
#' @examples
#'obj <- test_standard(10, 10)
#'mat <- abundance_matrix(obj)
#'stackplot(mat)
stackplot <- function(mat, col, legend, ...) {
  if(missing(col))
    col <- terrain.colors(dim(mat)[2])
  # If extinct, removes last spurious line
  if (is.nan(rownames(mat)[dim(mat)[1]]))
    mat <- mat[-dim(mat)[1],]
  N <- dim(mat)[2]
  time <- as.numeric(rownames(mat))
  for (i in (N-1):1) # sums populations IN REVERSE, may cause problems for 1-2 stages only
    mat[,i] = mat[,i] + mat[,i+1]
  mat <- cbind(mat, rep(0, length(time)))
  # maximo da escala do grafico
  maxp <-max(mat[,1])

  plot(0, type='n', ylim=c(0, maxp), xlim=c(0, max(time)), ylab="Population", xlab="Time", main="Facilitation dynamics", ...)
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

