library(pse)
mat.model.wrapper1.3stages <- function(d1,d3,g1,g2,r) {
	re <- array()
	re[1] <- limiting.rate(mat.model(n=3,Ds=c(d1,1,d3),Gs=c(g1,g2),R=r))
	re[2] <- limiting.rate(mat.model(n=3,Ds=c(d1,0,d3),Gs=c(g1,g2),R=r))
	re[3] <- facilitation.class(re[1],re[2])
	if(re[3]=="mixed") { # facilitation on d2 actually could have an efect!
		d2 <- .5
		sup <- 1
		inf <- 0
		limr <- limiting.rate(mat.model(n=3,Ds=c(d1,d2,d3),Gs=c(g1,g2),R=r))
		while(abs(limr) > .0001){
			if(limr>0){
				inf <- d2
			}
			else {
				sup <- d2
			}
			d2 <- (sup+inf)/2
			limr <- limiting.rate(mat.model(n=3,Ds=c(d1,d2,d3),Gs=c(g1,g2),R=r))
		}
		re[4] <- d2
	}
	else if(re[3] == "positive"){ #let's go crazy with that deathrate
		d2 <- 2
		limr <- limiting.rate(mat.model(n=3,Ds=c(d1,d2,d3),Gs=c(g1,g2),R=r))
		while(limr >0){
			d2 <- d2*2
			limr <- limiting.rate(mat.model(n=3,Ds=c(d1,d2,d3),Gs=c(g1,g2),R=r))
		}
		sup <- d2
		inf <- d2/2
		d2 <- (sup+inf)/2
		limr <- limiting.rate(mat.model(n=3,Ds=c(d1,d2,d3),Gs=c(g1,g2),R=r))
		while(abs(limr) > .0001){
			if(limr>0){
				inf <- d2
			}
			else {
				sup <- d2
			}
			d2 <- (sup+inf)/2
			limr <- limiting.rate(mat.model(n=3,Ds=c(d1,d2,d3),Gs=c(g1,g2),R=r))
		}
		re[4] <- d2
	}
	else{ # turns out mortality of seedlings doesn't even matter
		re[4] <- NA 
	}
	re[5] <- r*(g1/(g1+d1)) * g1/(g1+1) -d3
	re[6] <- r*(g1/(g1+d1)) -d3
	return(re)
}

mat.model.wrapper <- function(data){
	mapply(mat.model.wrapper1.3stages,data[,1],data[,2],data[,3],data[,4],data[,5])
}

# pse for finding parameters for which facilitation turns negative to positive growth
factors <- c("d1","d3","g1","g2","R")
q.cube <- "qunif"
q.arg.cube <- list(list(min=0,max=1),list(min=0,max=1),list(min=0,max=1),list(min=0,max=1),list(min=0,max=2)) #note sup(R) == 2
lhs.class.cube <- LHS(mat.model.wrapper,factors,2000,q.cube,q.arg.cube,res.names=c("lim.d2.1","lim.d2.0","class","d2crit","s1Rd3","s0Rd3"))
res.names=c("lim.d2.1","lim.d2.0","class","d2crit","s1Rd3","s0Rd3")
res <- lhs.class.cube$res[,,1]
colnames(res) <- res.names
lhs.data <- cbind(lhs.class.cube$data,res)

plot(R~d3,subset(lhs.data,class=="negative"),col="grey")
points(R~d3,subset(lhs.data,class=="mixed"),col="blue",pch=8)
points(R~d3,subset(lhs.data,class=="positive"),col="red",pch=3)
s1 <- .5/(.5+.5) #expected survival do adulthood when d2=0
s2 <- s1*(.5/(.5+1)) #expected survival do adulthood when d2=1
curve(x+0,lwd=1.2,add=T)
curve(x/s1,lwd=1.2,add=T,col="blue")
curve(x/s2,lwd=1.2,add=T,col="red")
legend(0.76,.29,c("both negative","mixed","both positive"),fill=c("grey","blue","red"),bg="white")
title("Dominant eigenvalues classed for d2=0 and d2=1")
text(.6,.5,"R=d3")
text(.9,2,"R=2d3",col="blue")
text(.4,2,"R=6d3",col="red")


