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
times <- seq(0,10,.2)         # array of times of interest
initialpop <- c(10,10,10,10)  # initial pop. sizes for the 3 stages plus the facilitator species
facindex <- 1                 # this will be the value by which facilitator decreases seeds' deathrates
radius <- 2                   # this is the distance up to which the facilitation affects the seed

ret <- facByRates(times=times, n=numstages, Ds=deathrates, Gs=growthrates, R=reproductionrate, fac=facindex, init=initialpop, rad=radius)
```

Another way to run the model, organizing the parameters by lifestage. The parameters in this example are the same as before, so we will reuse some of the variables. Obs.: this function is deprecated and may be removed in the future.
```r
par.seeds <- c(1, 0, 2, 0)      # parameters are (growthrate, reproductionrate, deathrate, radius). 
par.saps <- c(.2, 0, .2, 0)     # in our example reproduction rates for the first two stages is 0, but you can change 
par.adults <- c(0, 5, .2, 0)    # the last(adult) stage is not allowed to have positive growthrate
par.facilitator <- c(0,0,0,2)   # the facilitator also has parameters! the radius is the radius of facilitating effect
par <- c(par.seeds,par.saps,par.adults,par.facilitator)   # mind the order

ret <- test_parameter(times=times, num_stages=numstages, parameters=par, f=facindex, init=initialpop)
```

Either way, the return value is a list of lists. Each line corresponds to one individual, at one time.
You may convert this list to a dataframe and calculate the abundances through time:
```r
dt <- list2dataframe(ret)
ab <- abundance_matrix(dt)
```

If your rates are low and/or your time interval is small, it may happen that the times in the abundance matrix are less than what you expected. If the length of rownames(ab) is less than length(times), it means that there were spans of time during which no events happened. To fill in these blanks, you may use the following (warning: might be a slow function):
```r
ab <- fillTime(ab,times)
```

Having a reliable abundance matrix, you can plot your population in a stackplot. Obs.: currently this function ignores the last column, assumed to be the facilitator's column.
```r
stackplot(ab)
```

The package also include functions to plot the expected abundances according to a linear differential model. To produce the matrix corresponding to the ODE and calculate the solution (that is, the matrix exponential), run the following: 
```r
mat <- mat_model(n=numstages,Ds=deathrates,Gs=growthrates,R=reproductionrate)
so <- solution.matrix(p0=initialpop[1:numstages], M=mat, times=times)
```
Currently this matrix isn't in the same format as the other matrices, so here's a (very rough) code to allow you to compare this result graphicly to the result from the IBM:
```r
so <- t(rbind(t(so),rep(0,nrow(so))))   # adds a column of zeroes to the matrix
stackplot(s)
```
Note that this is the analitical solution to the ODE model that corresponds to the structured population in the *absence of facilitation*. One way to look at the effect of facilitation is changing the death rate as if it were under facilitation, and recalculating the solution.
```r
deathrates[1] <- deathrates[1]-facindex
mat <- mat_model(n=numstages,Ds=deathrates,Gs=growthrates,R=reproductionrate)
so <- solution.matrix(p0=initialpop, M=mat, times=times)
so <- t(rbind(t(so),rep(0,nrow(so))))   # adds a column of zeroes to the matrix
stackplot(s)
```

### Disclaimer

I am an undergrad applied math student, my skill in R programming is limited and this project is in development. This guide was made to allow others (ie my advisors) to understand the current state of the project so that we can comunicate. It is likely that most of the functions used above will be changed as this project develops, so that they can better fulfill our needs.
I will try and keep this guide updated. Please let me know if the code does not work.
