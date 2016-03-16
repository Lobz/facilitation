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

The below code creates a simulation with 3 lifestages, with facilitation reducing the death rate of the second stage, and competition between saplings and between adults, runs it up to time 10, and stores the result in ret. In this case, the facilitator has no dynamics.
```r
numstages <- 3
deathrates <- c(2, 0.2, 0.2)  # death rates for seed, sapling and adult
growthrates <- c(1, 0.2)      # transition rates seed-->sapling and sapling-->adult
reproductionrate <- 5         # reproduction rate (only adult)
times <- seq(0,10,.2)         # array of times of interest
initialpop <- c(10,10,10,10)  # initial pop. sizes for the 3 stages plus the facilitator species
facindex <- c(0,1)            # this will be the values by which facilitator decreases seeds and seedlings deathrates
effects <- c(0,0,0, 0,-0.5,0, 0,0,0.2)
radius <- c(0,0.5,2,2)        # this are the distances up to which the individuals can have effect on others, by stage + facilitator
h <- 100                      # arena height
w <- 100                      # arena width

dt <- facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, R=reproductionrate, interactions=effects, fac=facindex, init=initialpop, rad=radius, h=h, w=w)
```

The below code creates a simulation with 3 lifestages, with facilitation reducing the death rate of the second stage, runs it up to time 10, and stores the result in ret. In this case, the facilitator has no dynamics.
```r
numstages <- 3
deathrates <- c(2, 0.2, 0.2)  # death rates for seed, sapling and adult
growthrates <- c(1, 0.2)      # transition rates seed-->sapling and sapling-->adult
reproductionrate <- 5         # reproduction rate (only adult)
times <- seq(0,10,.2)         # array of times of interest
initialpop <- c(10,10,10,10)  # initial pop. sizes for the 3 stages plus the facilitator species
facindex <- c(0,1)            # this will be the values by which facilitator decreases seeds and seedlings deathrates
radius <- 2                   # this is the distance up to which the facilitation affects the seed
h <- 100                      # arena height
w <- 100                      # arena width

dt <- facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, R=reproductionrate, fac=facindex, init=initialpop, rad=radius, h=h, w=w)
```

Another way to run the model, organizing the parameters by lifestage. The parameters in this example are the same as before, so we will reuse some of the variables. Obs.: this function is deprecated and may be removed in the future.
```r
par.seeds <- c(1, 0, 2, 0)      # parameters are (growthrate, reproductionrate, deathrate, radius). 
par.saps <- c(.2, 0, .2, 0)     # in our example reproduction rates for the first two stages is 0, but you can change 
par.adults <- c(0, 5, .2, 0)    # the last(adult) stage is not allowed to have positive growthrate
par.facilitator <- c(0,0,0,2)   # the facilitator also has parameters! the radius is the radius of facilitating effect
par <- c(par.seeds,par.saps,par.adults,par.facilitator)   # mind the order

ret <- test_parameter(times=times, num_stages=numstages, parameters=par, f=facindex, init=initialpop)
dt <- list2dataframe(ret)
```

Either way, the return value of test_parameter is a list of lists. Each line corresponds to one individual, at one time.
You may convert this list to a dataframe (FacByRates does this internally) and calculate the abundances through time:
```r
ab <- abundance_matrix(dt)
```
Sometimes, the simulation may output the message "Nothing happens", and the times in the abundance matrix may be less than what you expected (the length of rownames(ab) is less than length(times)). This means that there were spans of time longer than your time interval during which no events happened, because your rates are low and/or your time interval is small. Because the simulator only records times in which events happen, the abundance matrix will have missing information. The following function will fill in blanks, setting the abundance in the time points listed in times to be equal to the last abundance value listed, which is the actual value if no events happened (warning: might be a slow function. WARNING: this function will produce points of false data whenever something did happen between a time point recorded in ab and a time point listed in times).
```r
ab <- fillTime(ab,times)
```

Having a reliable abundance matrix, you can plot your population in a stackplot. Obs.: the last column corresponds to the facilitator, so it must be removed from this plot.
```r
stackplot(ab[,1:numstages])
```
You can also plot it in a logaritmic scale to better visualize the growthrate of the species:
```r
stackplot(ab[,1:numstages],log.y=T)
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
Note that this is the analitical solution to the ODE model that corresponds to the structured population in the *absence of facilitation*. One way to look at the effect of facilitation is changing the death rate as if it were under facilitation, and recalculating the solution.
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
> limiting.rate(mat)
[1] 0.2625879
> limiting.rate(mat.f)
[1] 0.3466331
> fitted.rate(ab)
    slope
0.3099619
> fitted.rate(so)
    slope
0.2634011
> fitted.rate(so.f)
    slope
0.3468665
```
### Disclaimer

I am an undergrad applied math student, my skill in R programming is limited and this project is in development. This guide was made to allow others (ie my advisors) to understand the current state of the project so that we can comunicate. It is likely that most of the functions used above will be changed as this project develops, so that they can better fulfill our needs.
I will try and keep this guide updated. Please let me know if the code does not work.
