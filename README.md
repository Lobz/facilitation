# facilitation
A Rcpp framework for facilitation IBMs

## Installing the package

Install and load devtools:
```r
install.packages("devtools")
library(devtools)
```
Install this version from github and load it:
```r
install_github(repo = 'Lobz/facilitation')
library(facilitation)
```

## Running and testing:

The below code creates a simulation with 3 lifestages, with facilitation reducing the death rate of the second stage, and competition between saplings and between adults, runs it up to time 10, and stores the result in result. In this case, the facilitator has no dynamics.

The return value of facilitation is a list contaning all the parameters used and the data resulting from the simulation, with one line per individualat each life stage, with their (x,y) position, id, time at which they were born or grew to that stage and time at which they died or grew to the next stage.
```r
numstages <- 3
deathrates <- c(2, 0.2, 0.2)  # death rates for seed, sapling and adult
growthrates <- c(1, 0.2)      # transition rates seed-->sapling and sapling-->adult
reproductionrate <- 10        # reproduction rate (only adult)
dispersalradius <- 2	      # average distance a seed falls from the parent (distance is gaussian)
initialpop <- c(1,1,10,20)    # initial pop. sizes for the 3 stages plus the facilitator species
facindex <- c(0,1)            # this will be the values by which facilitator decreases seeds and seedlings deathrates
effects <- c(0,0,0, 0,-0.5,0, 0,0,-0.2) # the effects reducing deathrate (negative values increase deathrates)
radius <- c(0,0.5,2,2)        # this are the distances up to which the individuals can have effect on others, by stage + facilitator
maxt <- 10                    # time up to which the simulation shall run
h <- 50                       # arena height
w <- 50                       # arena width

results <- facilitation(maxtime=maxt, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)
dt <- results$data
```
You can plot the actual individuals in space in an animation with:
```r
times <- seq(0,maxt,.2)         # array of times of interest
spatialplot(results,times,tframe=0.1)
```
You can use the package `animation` to save the animation into a gif (set tframe to 0 (default) unless you want to waste a lot of time!).
```r
library(animation)
saveGIF(spatialplot(results,times),interval=0.1,movie.name="fac.gif") 
```
This is a shorthand if you want a snapshot of a given point in time:
```r
plotsnapshot(results,t=6.25)
```

You may calculate the abundances through time:
```r
times <- seq(0,maxt,.2)         # array of times of interest
ab <- abundance_matrix(results,times)
```
Having an abundance matrix, you can plot your population in a stackplot. Obs.: the last column corresponds to the facilitator, so it must be removed from this plot.
```r
stackplot(ab[,1:numstages])
```
You can also plot it in a logaritmic scale to better visualize the growthrate of the species:
```r
stackplot(ab[,1:numstages],log.y=T)
```

Note that you can choose as much detail in your abundance matrix as you'd like, changin the `times` parameter. Compare:
```r
stackplot(abundance_matrix(results,seq(0,maxt,length.out=20))[,1:numstages])
stackplot(abundance_matrix(results,seq(0,maxt,length.out=200))[,1:numstages])
```

The package also include functions to plot the expected abundances according to a linear differential model. To produce the matrix corresponding to the ODE and calculate the solution (that is, the matrix exponential), run the following: 
```r
mat <- mat.model(n=numstages,Ds=deathrates,Gs=growthrates,R=reproductionrate)
so <- solution.matrix(p0=initialpop[1:numstages], M=mat, times=times)
```
You can also plot the results (plot the whole matrix since there is no facilitator this time):
```r
stackplot(so)
```
Note that this is the analitical solution to the ODE model that corresponds to the structured population in the *absence of interactions*. One way to look at the effect of facilitation is changing the death rate as if it were under facilitation, and recalculating the solution.
```r
alpha <- c(0.2,0.2,0)		# first guess of proportions of individuals that are affected by facilitation 
deathrates.f <- deathrates-alpha*c(facindex,0)
mat.f <- mat.model(n=numstages,Ds=deathrates.f,Gs=growthrates,R=reproductionrate)
so.f <- solution.matrix(p0=initialpop[1:numstages], M=mat.f, times=times)
stackplot(so.f)
```

I will add a comparison example using the simulation results and the theoretical results.
```r
stackplot(ab[,1:numstages])
lines(so[,3]~rownames(so),lty=3)
lines(so[,3]+so[,2]~rownames(so),lty=3)
lines(so[,3]+so[,2]+so[,1]~rownames(so),lty=3)
lines(so.f[,3]~rownames(so.f),lty=2)
lines(so.f[,3]+so.f[,2]~rownames(so.f),lty=2)
lines(so.f[,3]+so.f[,2]+so.f[,1]~rownames(so.f),lty=2)
``` 
Also with log-scaled plots:
```r
stackplot(ab[,1:numstages], log.y=T)
lines(so[,3]~rownames(so),lty=3)
lines(so[,3]+so[,2]~rownames(so),lty=3)
lines(so[,3]+so[,2]+so[,1]~rownames(so),lty=3)
lines(so.f[,3]~rownames(so.f),lty=2)
lines(so.f[,3]+so.f[,2]~rownames(so.f),lty=2)
lines(so.f[,3]+so.f[,2]+so.f[,1]~rownames(so.f),lty=2)
``` 
I added some basic tools for comparing the results. Since the population grows exponentially, we will fit an exponential model to the population total using the nls function.
```r
limiting.rate(mat)
limiting.rate(mat.f)
mpm.fitted.rate(ab)
mpm.fitted.rate(so)
mpm.fitted.rate(so.f)
```
### Disclaimer

I am an undergrad applied math student, my skill in R programming is limited and this project is in development. This guide was made to allow others (ie my advisors) to understand the current state of the project so that we can comunicate. It is likely that most of the functions used above will be changed as this project develops, so that they can better fulfill our needs.
I will try and keep this guide updated. Please let me know if the code does not work.
