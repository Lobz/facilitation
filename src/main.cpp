
#include"Facilitation.hpp"
#include<iostream>
#include<fstream>
#include<string>
#include<Rcpp.h>

status_list run_tests(bool print, double maxtime, int num_stages, double * par, double dispersal, double * interactions, double w, double h, int *init, int bcond, int dkernel, int maxpop){
	int i;
	bool test=true;
	Arena *arena;
	status_list ret;
	int numturns=0;

	arena = new Arena(num_stages,par,dispersal,w,h,bcond,dkernel);
	arena->setInteractions(interactions);
	if(! arena->populate(init)) return {};

	if(print) std::cout << "#arena populated!\n";
	if(print) std::cout << "time,species,individual,x,y\n";

	if(print) arena->print();
	while(arena->getTotalTime() < maxtime && test){
		test = arena->turn();
		numturns++;
		if(arena->getTotalAbundance() > maxpop) {
			std::cout << "Maximum population (" << maxpop << ") reached. Stopping...";
			test = false;
		}
		//				std::cout << "#Turn " << i << ",";
		//				std::cout << "#Time: " << arena->getTotalTime() << "\n";
	}

	std::cout << "#Finished. Total number os turns: " << numturns << "\n";

	ret= arena->finalStatus();
//	delete(arena); // this line is causing weird trouble
	return ret;
}

// [[Rcpp::export]]
Rcpp::List test_parameter(double maxtime,int num_stages,Rcpp::NumericVector parameters, double dispersal, Rcpp::NumericVector interactions, Rcpp::IntegerVector init, double w=100, double h=100, int bcond=1, int dkernel=1, int maxpop=30000){
	int *in;
	Rcpp::List ret;
	in = init.begin();

	ret = run_tests(false,maxtime, num_stages,parameters.begin(),dispersal,interactions.begin(),w,h,in,bcond,dkernel,maxpop);

	return ret;
}
