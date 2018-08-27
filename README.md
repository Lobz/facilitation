# facilitation
[![Travis-CI Build Status](https://travis-ci.org/Lobz/facilitation.svg?branch=master)](https://travis-ci.org/Lobz/facilitation)
[![CRAN Status](https://img.shields.io/cran/v/facilitation.svg)](https://cran.r-project.org/package=facilitation)
[![License](https://img.shields.io/badge/license-GPLv2-brightgreen.svg)](LICENSE)

A Rcpp framework for plant-plant interactions IBMs

## Installing the package

```r
install.packages("facilitation")
library(facilitation)
vignette("facilitation")
```
### Development version

If you want to install the latest development snapshot, install and load the library devtools:
```r
install.packages("devtools")
library(devtools)
```
Then install the master version from GitHub and load it:
```r
install_github(repo = 'Lobz/facilitation', build_vignettes = TRUE)
library(facilitation)
vignette("facilitation")
```
