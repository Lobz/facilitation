#include"Facilitation.hpp"
#include<iostream>

extern "C" int test_from_cin(){

	int num_stages, h, w, i, *init;
	double fac, **par;
	bool test=true;
	Arena *arena;

	srand(1975659);

	std::cout << "Hello!\n";
	
	std::cout << "how many stages?\n";
	std::cin >> num_stages;
	std::cout << "supply width, height and facilitation parameter.\n";
	std::cin >> w; std::cin >> h; std::cin >> fac;
	std::cout << "facilitation parameter: " << fac << "\n";
	std::cout << "supply N+1 parameter matrix in lines of 'G R D Radius'\n";
	par = (double**)malloc((num_stages+1)*(sizeof(double*)));
	for(i=0;i<num_stages+1;i++){
		par[i] = (double*)malloc(4*(sizeof(double)));
		std::cin >> par[i][0]; std::cin >> par[i][1]; std::cin >> par[i][2]; std::cin >> par[i][3];
	}
	std::cout << "supply initial populations\n";
	init = (int*)malloc((num_stages+1)*(sizeof(int)));
	for(i=0;i<num_stages+1;i++){
		std::cin >>init[i];
	}
	std::cout << "okay!\n";

	arena = new Arena(num_stages,par,fac,w,h);
	arena->populate(init);

	std::cout << "arena populated!\n";

	for(i=1;i<1000 && test;i++) {
		std::cout << "Turn " << i << "\n";
		arena->print();
		test = arena->turn();
	}

	return 0;

}

