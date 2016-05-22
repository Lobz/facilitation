#include<list>
#include<cstdlib>
#include<iostream>
#include<array>
#include"Position.hpp"
#include"Facilitation.hpp"
#include<Rcpp.h>

// [[Rcpp::export]]
class Exportable {
	public:
	Position p;
	Arena *a;

	Exportable(double x, double y):p(x,y){
		a = NULL;
	}

	double getY(){ return p.y; }

};


