#include"Random.hpp"
#include<Rcpp.h>

double Random(double max){
	return Rcpp::as<double>(Rcpp::runif(1,0,max));
}

bool Bernoulli(double p){
	return Random(1) < p ;
}

double Exponential(double r){
	Rcpp::NumericVector s = Rcpp::rexp(1,r);
	return Rcpp::as<double>(s);
}
