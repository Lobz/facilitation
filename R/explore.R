limiting.rate <- function(mat){tryCatch(max(Re(eigen(mat)$values)),error=function(e) NA)}

fit.data <- function(ab.mat){
	y <- log(rowSums(ab.mat))
	x <- as.numeric(rownames(ab.mat))
	regression <- lm(y~x)
	regression
}

fit.data2 <- function(ab.mat,mat){
	total <- data.frame(rowSums(ab.mat))
	total$times <- as.numeric(rownames(ab.mat))
	names(total) <- c("y","x")

	e <- sort(Re(eigen(mat)$values))
	regression <- nls(y ~exp(intersect1+slope1 * x) + exp(intersect2+slope2 * x), data=total, 
			  start=list(intersect1=1,slope1=e[3],intersect2=1,slope2=e[2]))
	regression
}

mpm.fitted.rate <-function(ab.mat){
	regression <- fit.data(ab.mat)
	coef(regression)[2]
}
