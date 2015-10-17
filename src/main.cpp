
#include"Facilitation.hpp"
#include<iostream>
#include<fstream>
#include<string>
#include<Rcpp.h>

status_list run_tests(double maxTime, int num_stages, double * par, double fac, double w, double h, int *init){
	int i;
	bool test=true;
	Arena *arena;
	status_list ret = {};

	arena = new Arena(num_stages,par,fac,w,h);
	arena->populate(init);

//	std::cout << "#arena populated!\n";
//	std::cout << "time,species,individual,x,y\n";

	for(i=1;arena->getTotalTime() < maxTime && test;i++) {
		//std::cout << "#Turn " << i << "\n";
		//arena->print();
		test = arena->turn();
		ret.splice(ret.end(),arena->getStatus());
	}


	return ret;
}

// [[Rcpp::export]]
Rcpp::List test_basic(std::string filename,std::string outfilename){

	Rcpp::List ret;
	std::ifstream inputfile(filename);
	std::ofstream outputfile(outfilename);
	auto coutbuf = std::cout.rdbuf(outputfile.rdbuf()); //save and redirect output

	int num_stages, h, w, i, *init;
	double fac, *par;


	if(!inputfile) {
		std::cout << "#file \""<< filename << "\"not found\n";
		return NULL;
	}
	
	std::cout << "#how many stages?\n";
	inputfile >> num_stages;
	std::cout << "#supply width, height and facilitation parameter.\n";
	inputfile >> w; inputfile >> h; inputfile >> fac;
	std::cout << "#facilitation parameter: " << fac << "\n";
	std::cout << "#supply N+1 parameter matrix in lines of 'G R D Radius'\n";
	par = (double*)malloc((num_stages+1)*4*(sizeof(double*)));
	for(i=0;i<num_stages+1;i++){
		inputfile >> par[i*4+0]; inputfile >> par[i*4+1]; inputfile >> par[i*4+2]; inputfile >> par[i*4+3];
	}
	std::cout << "#supply initial populations\n";
	init = (int*)malloc((num_stages+1)*(sizeof(int)));
	for(i=0;i<num_stages+1;i++){
		inputfile >>init[i];
	}
	inputfile.close();
	std::cout << "#okay!\n";

	ret = run_tests(10,num_stages,par,fac,w,h, init);

	std::cout.rdbuf(coutbuf); //reset to standard output again

	return ret;

}

// [[Rcpp::export]]
Rcpp::List test_parameter(double maxTime, int num_stages,Rcpp::NumericVector parameters, double f, double w, double h, Rcpp::IntegerVector init){
	double *par;
	int *in;
	Rcpp::List ret;
	in = init.begin();
	par = parameters.begin();

	ret = run_tests(maxTime, num_stages,par,f,w,h,in);

	return ret;
}
