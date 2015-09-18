#include"Facilitation.hpp"
#include<iostream>
#include<fstream>
#include<string>
#include<Rcpp.h>

int run_tests(int num_stages, double **par, double fac, double w, double h, int *init){
	int i;
	bool test=true;
	Arena *arena;

	srand(1975659);
	arena = new Arena(num_stages,par,fac,w,h);
	arena->populate(init);

	std::cout << "#arena populated!\n";
	std::cout << "time,species,individual,x,y\n";

	for(i=1;i<1000 && test;i++) {
		std::cout << "#Turn " << i << "\n";
		arena->print();
		test = arena->turn();
	}


	return 0;
}

// [[Rcpp::export]]
int test_basic(std::string filename){

	std::ifstream inputfile;

	int num_stages, h, w, i, *init;
	double fac, **par;

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
	inputfile.close();
	std::cout << "#okay!\n";

	return run_tests(num_stages,par,fac,w,h, init);

}

// [[Rcpp::export]]
int test_parameter(Rcpp::NumericVector parameters, double w, double h, int nb, int nf){
	double **par;
	int *init;
	par = (double**)malloc(sizeof(double*));
	par[1] = par[0] = parameters.begin();
	init = (int*)malloc(2*sizeof(int));
	init[0]=nb; init[1]=nf;

	return run_tests(1,par,0.1,w,h,init);

}

