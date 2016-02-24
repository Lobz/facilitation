limiting.rate <- function(mat){max(Re(eigen(mat)$values))}

fitted.rate <- function(ab.mat){
	total <- data.frame(rowSums(ab.mat))
	total$times <- as.numeric(rownames(ab.mat))
	names(total) <- c("y","x")
	regression <- nls(y ~intersect * exp(slope * x), data=total, start=list(intersect=1,slope=1))
	coef(regression)[2]
}

solveandfit.rate <- function(mat){
	so <- solution.matrix(rep(1,nrow(mat)),mat,seq(1,30,0.05))
	fitted.rate(so)
}

