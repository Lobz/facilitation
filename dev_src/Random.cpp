#include"Random.hpp"
double Random(double max){
	return rand()*max/(double)RAND_MAX;
}

bool Bernoulli(double p){
	return Random(1) < p ;
}

double Exponential(double r){
	return Random(2/r);
}
