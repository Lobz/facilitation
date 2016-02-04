
#include"Facilitation.hpp"
#include<iostream>
#include<fstream>
#include<string>
#include<Rcpp.h>

status_list run_tests(bool print, int ntimes,double * times, int num_stages, double * par, double * fac, double w, double h, int *init){
	int i;
	double nextTime, timeInterval;
	bool test=true;
	Arena *arena;
	status_list ret = {};

	arena = new Arena(num_stages,par,fac,w,h);
	if(! arena->populate(init)) return ret;;

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
Rcpp::List test_basic(std::string filename,std::string outfilename = ""){

	Rcpp::List ret;
	int num_stages, h, w, i, *init,ntime=50;
	double fac, *par, *time;
	bool out = (outfilename!="");

	std::ifstream inputfile(filename);
	std::ofstream outputfile(out? outfilename : "output_default.txt");
	auto coutbuf = std::cout.rdbuf(outputfile.rdbuf()); //save and redirect output

	if(!inputfile) {
		std::cerr << "#file \""<< filename << "\"not found\n";
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

	time = (double*) malloc(ntime*sizeof(double));
	for(i=1,time[0]=0;i<ntime;i++) time[i] = time[i-1] + 0.1;
	ret = run_tests(out,ntime,time,num_stages,par,fac,w,h, init);

	if(out) std::cout.rdbuf(coutbuf); //reset to standard output again

	return ret;

}

// [[Rcpp::export]]
Rcpp::List test_parameter(Rcpp::NumericVector times, int num_stages,Rcpp::NumericVector parameters, Rcpp::NumericVector fac, Rcpp::IntegerVector init, double w=10, double h=10){
	int *in;
	Rcpp::List ret;
	in = init.begin();

	ret = run_tests(false,times.length(),times.begin(), num_stages,parameters.begin(),fac.begin(),w,h,in);

	return ret;
}
