#include"Species.hpp"


Species::Species(double num, Arena ar){
	num_stages = num;
	LG = (double*)malloc((num-1)*sizeof(double));
	LR = (double*) malloc(num*sizeof(double));
	LS = (double*)malloc(num*sizeof(double));
	LRad = (double*)malloc(num*sizeof(double));

	population = new DLL<Individual>;
	arena = ar;
}

double Species::getG(int stage, double x, double y){
	return LG[stage];
}
double Species::getR(int stage, double x, double y){
	return LR[stage];
}
double Species::getS(int stage, double x, double y){
	return LS[stage];
}
double Species::getRad(int stage, double x, double y){
	return LRad[stage];
}
