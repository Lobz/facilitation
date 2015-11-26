#include<cstdlib>
#ifndef _RANDOM_MINE
#define _RANDOM_MINE
double Random(double max);

bool Bernoulli(double p);

double Exponential(double r);

double Normal(double m, double v);

short RandomSign();
#endif
