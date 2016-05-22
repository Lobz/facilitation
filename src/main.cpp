
#include"Facilitation.hpp"
#include<iostream>
#include<fstream>
#include<string>
#include<Rcpp.h>

status_list run_tests(bool print, int ntimes,double * times, int num_stages, double * par, double dispersal, double * interactions, double w, double h, int *init, int bcond, int dkernel){
	int i;
	bool test=true;
	Arena *arena;
	status_list ret = {};

	arena = new Arena(num_stages,par,dispersal,w,h,bcond,dkernel);
	arena->setInteractions(interactions);
	if(! arena->populate(init)) return ret;

	if(print) std::cout << "#arena populated!\n";
	if(print) std::cout << "time,species,individual,x,y\n";

	ret.splice(ret.end(),arena->getStatus());
	for(i=1;i < ntimes && test;i++) {
		if(print) std::cout << "#Turn " << i << ",";
		if(print) std::cout << "#Time: " << arena->getTotalTime() << "\n";
		if(print) arena->print();
		if(arena->getTotalTime() >= times[i]) std::cout << "Nothing happens\n";
		else { 
			while(arena->getTotalTime() < times[i] && test){
				test = arena->turn();
//				std::cout << "#Turn " << i << ",";
//				std::cout << "#Time: " << arena->getTotalTime() << "\n";
			}

			ret.splice(ret.end(),arena->getStatus());
		}
	}


	return ret;
}

// [[Rcpp::export]]
Rcpp::List test_parameter(Rcpp::NumericVector times, int num_stages,Rcpp::NumericVector parameters, double dispersal, Rcpp::NumericVector interactions, Rcpp::IntegerVector init, double w=100, double h=100, int bcond=1, int dkernel=1){
	int *in;
	Rcpp::List ret;
	in = init.begin();

	ret = run_tests(false,times.length(),times.begin(), num_stages,parameters.begin(),dispersal,interactions.begin(),w,h,in,bcond,dkernel);

	return ret;
}
