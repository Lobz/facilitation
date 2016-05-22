dados <- read.csv("dadosPSE.csv")
mix <- subset(dados,class=="mixed")
pos <- subset(dados,class=="positive")
neg <- subset(dados,class=="negative")
noneg <- rbind(mix,pos)


plot(neg$R~neg$d3, xlab="adult death rate (d3)", ylab="reproduction rate (R)", xlim=c(0,1), ylim=c(0,2),col="grey")
points(pos$R~pos$d3)
points(mix$R~mix$d3, col="red")
curve(x^1, add=T)
legend(0,2,c("negative","mixed","positive"),fill=c("grey","red","black"),bg="white")
title("eigenvalue class when R > d3")


# histograma
hist(dados$d3,breaks=20)
hist(noneg$d3,breaks=20,col="red",add=T)
hist(pos$d3,breaks=20,col="gray",add=T)
legend(0.73,70,c("negative","mixed","positive"),fill=c("white","red","gray"),bg="white")

# boxplots
boxplot(dados$R - dados$d3 ~ dados$res2)
title("R - d3 boxplots for positive (0), mixed (1) and negative (2) eigenvalues")
savePlot("diffboxplotsgen.png")
boxplot(dadosRd3$R - dadosRd3$d3 ~ dadosRd3$res2)
title("R - d3 boxplots conditioned on R > d3")
savePlot("diffboxplotscond.png")
