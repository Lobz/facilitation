#include"Facilitation.hpp"
#include<iostream>
#include<fstream>
#include<string>
#include<Rcpp.h>

int test_basic(std::string filename){

	std::ifstream inputfile;

	int num_stages, h, w, i, *init;
	double fac, **par;
	bool test=true;
	Arena *arena;

	srand(1975659);

	inputfile.open(filename);
	if(!inputfile) {
		std::cout << "#file \""<< filename << "\"not found\n";
		return 0;
	}
	
	std::cout << "#how many stages?\n";
	inputfile >> num_stages;
	std::cout << "#supply width, height and facilitation parameter.\n";
	inputfile >> w; inputfile >> h; inputfile >> fac;
	std::cout << "#facilitation parameter: " << fac << "\n";
	std::cout << "#supply N+1 parameter matrix in lines of 'G R D Radius'\n";
	par = (double**)malloc((num_stages+1)*(sizeof(double*)));
	for(i=0;i<num_stages+1;i++){
		par[i] = (double*)malloc(4*(sizeof(double)));
		inputfile >> par[i][0]; inputfile >> par[i][1]; inputfile >> par[i][2]; inputfile >> par[i][3];
	}
	std::cout << "#supply initial populations\n";
	init = (int*)malloc((num_stages+1)*(sizeof(int)));
	for(i=0;i<num_stages+1;i++){
		inputfile >>init[i];
	}
	std::cout << "#okay!\n";

	arena = new Arena(num_stages,par,fac,w,h);
	arena->populate(init);

	std::cout << "#arena populated!\n";
	std::cout << "time,species,individual,x,y\n";

	for(i=1;i<1000 && test;i++) {
		std::cout << "#Turn " << i << "\n";
		arena->print();
		test = arena->turn();
	}

	inputfile.close();

	return 0;

}

// [[Rcpp::export]]
RcppExport SEXP r_test(SEXP a) {
	std::string filename = Rcpp::as<std::string>(a);
	return Rcpp::wrap(test_basic(filename));
}

