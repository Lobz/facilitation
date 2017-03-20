#include"Individual.h"
#include<iostream>
#include<fstream>
#include<string>
#include<Rcpp.h>

// [[Rcpp::export]]
Rcpp::DataFrame simulation(double maxtime,int num_stages,Rcpp::NumericVector parameters, double dispersal, Rcpp::NumericVector interactions, Rcpp::IntegerVector init, double w=100, double h=100, int bcond=1, int dkernel=1, int maxpop=30000){
	int *in;
    double *par, *inter;
	bool test=true;
	Arena *arena;
	History *ret;
	int numturns=0;

	in = init.begin();
    par = parameters.begin();
    inter = interactions.begin();

	arena = new Arena(num_stages+1,par,w,h,bcond);
	arena->setInteractions(inter,0);
	// create beneficiary
	arena->createStructuredSpecies(1,num_stages,dispersal,dkernel);
	// create facilitator
	arena->createSimpleSpecies(num_stages+1,dispersal,dkernel);
	if(! arena->populate(in)) return NULL;

	while(arena->getTotalTime() < maxtime && test){
		test = arena->turn();
		numturns++;
		if(arena->getTotalAbundance() > maxpop) {
			Rcpp::warning("Maximum population reached. Stopping...");
			test = false;
		}
	}

	ret = arena->finalStatus();
	return Rcpp::DataFrame::create(Rcpp::Named("sp")=ret->sp_list,Rcpp::Named("id")=ret->id_list,
			Rcpp::Named("x")=ret->x_list,Rcpp::Named("y")=ret->y_list,
			Rcpp::Named("begintime")=ret->beginTime_list,Rcpp::Named("endtime")=ret->endTime_list);
}
