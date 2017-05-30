# facilitation
A Rcpp framework for plant-plant interactions IBMs

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

# Example 1

The below code creates a simulation with 3 lifestages, with facilitation reducing the death rate of the second stage, and competition between saplings and between adults, runs it up to time 10, and stores the result in results. In this case, the facilitator has no dynamics.

The return value is a list contaning all the parameters used and the data resulting from the simulation, with one line per individual at each life stage, with their (x,y) position, id, time at which they were born or grew to that stage and time at which they died or grew to the next stage.
```r
numstages <- 3
deathrates <- c(2, 0.2, 0.2)  # death rates for seed, sapling and adult
growthrates <- c(1, 0.2)      # transition rates seed-->sapling and sapling-->adult
reproductionrate <- 10        # reproduction rate (only adult)
dispersalradius <- 2	      # average distance a seed falls from the parent (distance is gaussian)
init <- c(1,1,10,20)          # initial pop. sizes for the 3 stages plus the facilitator species
facindex <- c(0,1)            # this will be the values by which facilitator decreases seeds and seedlings deathrates
effects <- c(0,0,0, 0,-0.5,0, 0,0,-0.2) # the effects reducing deathrate (negative values increase deathrates)
radius <- c(0,0.5,2,2)        # this are the distances up to which the individuals can have effect on others, by stage + facilitator
maxt <- 10                    # time up to which the simulation shall run
h <- 50                       # arena height
w <- 50                       # arena width

results <- facilitation(maxtime=maxt, n=numstages, Ds=deathrates, Gs=growthrates, dispersal=dispersalradius, R=reproductionrate, interactions=effects, fac=facindex, init=init, rad=radius, h=h, w=w)
```

The function `facilitation` is currently implemented as a wrapper to the more general function,
`community`, in which you can have any number of species, each of them structured or not, with
interaction defined stage-to-stage.

# Example 2:
The below code creates a simulation with two species, with 3 and 2 lifestages respectively, with facilitation reducing the death rate of the juveline stages, and intra and inter-specific compettion; runs it up to time 10, and stores the result in results.

```r
### Two species competition+facilitation
maxt <- 10
dispersal<-2

nstages <- c(3,2)
init <- list(c(100,0,10),c(100,30))
### parameter matrix has one stage per row
###               D G R Rad
param <- matrix(c(2,1,0,0, 1,1,0,.1, .5,0,6,1, 1,1,0,.2, .5,0,2,2), byrow=T, nrow=5) 
### interaction matrix: positive values represent facilitation, negative ones, competition
interact <- matrix(c(0,0,0,0,0, 0,-.1,+.1,-.1,0, 0,0,-.1,0,-.2, ## effects over species 1
                                0,-.2,+.2,-.1,0, 0,0,-.2,0,-.1),ncol=5) ## effects over species 2
results <- community(maxt,nstages,param,dispersal,init,interactions=interact)
```

See the script `examples/test_community.R` for a few more examples.

# Showing the results

You can plot the actual individuals in space in an animation with:
```r
times <- seq(0,maxt,.2)         # array of times of interest
spatialplot(results,times,tframe=0.1)
```
You can use the package `animation` to save the animation into a gif (set tframe to 0 (default) unless you want to waste a lot of time!).
```r
library(animation)
saveGIF(spatialplot(results,times),interval=0.1,movie.name="sim.gif") 
```
This is a shorthand if you want a snapshot of a given point in time:
```r
plotsnapshot(results,t=6.25)
```

You may calculate the abundances through time:
```r
times <- seq(0,maxt,.2)         # array of times of interest
ab <- abundance.matrix(results,times)
```
Having an abundance matrix, you can plot your population in a stackplot. Obs.: the stackplot makes
most sense if you plot only one species at a time, so let's plot the columns 1:3, ie, species 1.
```r
stackplot(ab[,1:3])
```
You can also plot it in a logaritmic scale to better visualize the growthrate of the species:
```r
stackplot(ab[,1:3],log.y=T)
```

Note that you can choose as much detail in your abundance matrix as you'd like, changin the `times` parameter. Compare:
```r
stackplot(abundance.matrix(results,seq(0,maxt,length.out=20))[,1:3])
stackplot(abundance.matrix(results,seq(0,maxt,length.out=200))[,1:3])
```
The package also includes functions to plot the expected abundances according to a linear differential model. To produce the matrix corresponding to the ODE and calculate the solution (that is, the matrix exponential), run the following:
```r
mat <- mat.model(n=numstages,Ds=deathrates,Gs=growthrates,R=reproductionrate)
so <- solution.matrix(p0=init[1:3], M=mat, times=times)
```
You can also plot the results (plot the whole matrix since there is only one species this time):
```r
stackplot(so)
```
Note that this is the analitical solution to the ODE model that corresponds to the structured population in the *absence of interactions*.

There are some other functions implemented in the package, mostly to simplify analysis.

### Disclaimer

I am an applied math student, my skill in R programming is limited and this project is in development. This guide was made to allow others (ie my advisors) to understand the current state of the project so that we can comunicate. It is likely that most of the functions used above will be changed as this project develops, so that they can better fulfill our needs.
I will try and keep this guide updated. Please let me know if the code does not work.
