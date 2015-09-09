#include<cstdlib>
#include<random>
#ifndef _RANDOM_MINE
#define _RANDOM_MINE
double Random(double max){
	std::default_random_engine generator;
	std::uniform_real_distribution<double> distribution(0.0,max);
	return distribution(generator);
}

bool Bernoulli(double p){
	std::default_random_engine generator;
	std::bernoulli_distribution distribution(p);
	return distribution(generator);
}

double Exponential(double r){
	std::default_random_engine generator;
	std::exponential_distribution<double> distribution(r);
	return distribution(generator);
}
#endif
