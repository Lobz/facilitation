#include"Individual.h"
#include<iostream>
#include<fstream>
#include<string>
#include<Rcpp.h>

History * run_simulation(double maxtime, int num_stages, double * par, double dispersal, double * interactions, double w, double h, int *init, int bcond, int dkernel, int maxpop){
	bool test=true;
	Arena *arena;
	History *ret;
	int numturns=0;

	arena = new Arena(num_stages+1,par,w,h,bcond);
	arena->setInteractions(interactions);
	// create beneficiary
	arena->createStructuredSpecies(1,num_stages,dispersal,dkernel);
	// create facilitator
	arena->createSimpleSpecies(num_stages+1,dispersal,dkernel);
	if(! arena->populate(init)) return NULL;

	while(arena->getTotalTime() < maxtime && test){
		test = arena->turn();
		numturns++;
		if(arena->getTotalAbundance() > maxpop) {
			Rcpp::warning("Maximum population reached. Stopping...");
			test = false;
		}
	}

	ret = arena->finalStatus();
//	delete(arena); // this line is causing weird trouble
	return ret;
}

// [[Rcpp::export]]
Rcpp::DataFrame simulation(double maxtime,int num_stages,Rcpp::NumericVector parameters, double dispersal, Rcpp::NumericVector interactions, Rcpp::IntegerVector init, double w=100, double h=100, int bcond=1, int dkernel=1, int maxpop=30000){
	int *in;
	History * ret;
	in = init.begin();

	ret = run_simulation(maxtime, num_stages,parameters.begin(),dispersal,interactions.begin(),w,h,in,bcond,dkernel,maxpop);

	return Rcpp::DataFrame::create(Rcpp::Named("sp")=ret->sp_list,Rcpp::Named("id")=ret->id_list,Rcpp::Named("x")=ret->x_list,Rcpp::Named("y")=ret->y_list,Rcpp::Named("begintime")=ret->beginTime_list,Rcpp::Named("endtime")=ret->endTime_list);
}
