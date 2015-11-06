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

The below code creates a simulation with 3 lifestages, runs it up to time 3, and stores the result in ret. In this case, the facilitator has no dynamics.
```r
numstages <- 3
deathrates <- c(2, 0.2, 0.2)  # death rates for seed, sapling and adult
growthrates <- c(1, 0.2)      # transition rates seed-->sapling and sapling-->adult
reproductionrate <- 5         # reproduction rate (only adult)
times <- seq(0,3,0.3)         # array of times of interest
initialpop <- c(10,10,10,10)  # initial pop. sizes for the 3 stages plus the facilitator species
facindex <- 1                 # this will be the value by which facilitator decreases seeds' deathrates

ret <- facByRates(times=timers, n=numstages, Ds=deathrates, Gs=growthrates, R=reproductionrate, fac=facindex, init=initialpop)
```

Another way to run the model, organizing the parameters by lifestage. The parameters in this example are the same as before, so we will reuse some of the variables.
```r
par.seeds <- c(1, 0, 2, 0)      # parameters are (growthrate, reproductionrate, deathrate, radius). 
par.saps <- c(.2, 0, .2, 0)     # only the last(adult) stage can have positive reproduction rate 
par.adults <- c(0, 5, .2, 0)    # the last(adult) stage is not allowed to have positive growthrate
par.facilitator <- c(0,0,0,1)   # the facilitator also has parameters! the radius is the radius of facilitating effect
par <- c(par.seeds,par.sads,par.adults,par.facilitator)   # mind the order

ret <- test_parameter(times=timers, num_stages=numstages, parameters=par, f=facindex, init=initialpop)
```

Either way, the return value is a list of lists. Each line corresponda to one individual, at one time.
You may convert this list to a dataframe and calculate the abundances through time:
```r
dt <- list2dataframe(ret)
ab <- abundance_matrix(dt)
```

If your rates are low and/or your time interval is small, it may happen that the times in the abundance matrix are less than what you expected. If the length of rownames(ab) is less than length(times), it means that there were spans of time during which no events happened. To fill in these blanks, you may use the following (warning: might be a slow function):
```r
abf <- fillTime(ab,times)
```

Having a reliable abundance matrix, you can plot your population in a stackplot. Obs.: currently this function ignores the last column, sopposed to be the facilitator's column.
```r
stackplot(abf)
```


