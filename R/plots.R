#' Plots 
#' 
#' The \code{stackplot} function produces a stacked plot of the population over time.
#' @param mat A population matrix, as produced by \code{\link{abundance_matrix}}
#' @param col Optional. A color vector
#' @param \dots Further parameters to be passed to the lower leve plot
#' @examples
#'obj <- test_standard(10, 10)
#'mat <- abundance_matrix(obj)
#'stackplot(mat)
stackplot <- function(mat, col, ...) {
  if(missing(col))
    col <- terrain.colors(dim(mat)[2]-1)
  # If extinct, removes last spurious line
  if (is.nan(rownames(mat)[dim(mat)[1]]))
    mat <- mat[-dim(mat)[1],]
  # facilitator is the last column, so we remove it
  facidx <- dim(mat)[2]
  pop <- mat[,-facidx]
  time <- as.numeric(rownames(mat))
  for (i in (facidx-2):1) # sums populations IN REVERSE, may cause problems for 1-2 stages only
    pop[,i] = pop[,i] + pop[,i+1]
  pop <- cbind(pop, rep(0, length(time)))
  # maximo da escala do grafico
  maxp <-max(pop[,1])

  plot(0, type='n', ylim=c(0, maxp), xlim=c(0, max(time)), ylab="Population", xlab="Time", main="Facilitation dynamics", ...)
  x <- c(time, rev(time))
  for (i in 1:(facidx-1)) {
    y <- c(pop[,i], rev(pop[,i+1]))
    polygon(x,y, col=col[i])
  }
  legend("topleft", legend=c("Seeds", "Juveniles", "Adults"), fill=col)
}

