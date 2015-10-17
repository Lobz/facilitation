#include"Random.hpp"
#include<Rcpp.h>


// [[Rcpp::export]]
double Random(double max){
	return Rcpp::as<double>(Rcpp::runif(1,0,max));
}

// [[Rcpp::export]]
bool Bernoulli(double p){
	return Random(1) < p ;
}

// [[Rcpp::export]]
double Exponential(double r){
	Rcpp::NumericVector s = Rcpp::rexp(1,r);
	return Rcpp::as<double>(s);
}

// [[Rcpp::export]]
short RandomSign(){
	return Bernoulli(0.5)?-1:1;
}
