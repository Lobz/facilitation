
NPAR <- 100
NREP <- 15
factors <- c("d1","d2","d3","g1","g2","R") #,"n1","n2","n3","nf","f","c2","c3","disp")
# pse in a cube (0,1)^6
q.cube <- "qunif"
q.arg.cube <- list(min=0,max=1)
maxt=.5
lhs.cube <- LHS(NULL,factors,NPAR,q.cube,q.arg.cube)
	res.names=c("eigen","lm.so","sumexp.so","egr","distance","lm.m")
		#,"lm.f","lm.l","lm.c",
		 #   "sumexp.m","sumexp.f","logr.l","logK.l","logr.c","logK.c"))

inputdata <- lhs.cube$data
inputdata$R <- inputdata$R*4 # I want R from 0 to 4
#inputdata$disp <- 10*inputdata$disp
#inputdata$c2 <- 3*inputdata$c2
#inputdata$c3 <- 3*inputdata$c3
#inputdata$n1 <- round(100*inputdata$n1)
#inputdata$n2 <- round(100*inputdata$n2)
#inputdata$n3 <- round(100*inputdata$n3)
#inputdata$nf <- round(100*inputdata$nf)
results <- list()

for(i in 1:NPAR){
	for(j in 1:NREP){
		results[[NREP*(i-1)+j]] <- wrapper(inputdata,i,5)
	}
}
data<-data.frame(matrix(unlist(results),NPAR*NREP,byrow=T))
names(data)<-res.names


hist(dados$distance,breaks=100,xlab="Distância quadrada média do log",ylab="Frequência",main="Distância entre modelo matricial e simulacional")
hist(subset(dados,eigen>0)$distance,col=2,add=T)
legend(.8,300,c("Autovalor negativo","Autovalor positivo"),col=c("white","red"),fill=c("white","red"))

