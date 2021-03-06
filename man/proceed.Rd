% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/community.R
\name{proceed}
\alias{proceed}
\alias{restart}
\title{Proceeding / restarting a simulation}
\usage{
proceed(data, time)

restart(data, time, start = 0)
}
\arguments{
\item{data}{result of a simulation, created by \code{\link{community}}}

\item{time}{numeric: for how long to extend the simulation}

\item{start}{numeric: an instant in time to begin from}
}
\description{
The function \code{proceed} proceeds with a stopped simulation. The function \code{restart} 
turns back time and restarts a simulation from time t.
}
