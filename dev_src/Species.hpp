#include<stdlib.h>

class Arena {
	Species *species;
	int numberSpecies;
	double width, height;


}


class Species {
	protected:
	int num_stages;
	char name[30];
	char *name_stages[30]
	double *LG, *LR, *LS, *LRad;

	Arena arena;
	DLL<Individual> population;

	Species(double num);

	virtual:
	double getG(int stage, double x, double y);
	double getR(int stage, double x, double y);
	double getS(int stage, double x, double y);
	double getRad(int stage, double x, double y);
	double getTotalRate();
	void newIndividual(int stage, double x, double y);
	void newIndividual(double x, double y);
};


class Individual {
	protected:
	int lifestage;
	double R, S, G, lambda, x, y;
	Species species;

	public:
	Individual(Species sp, double x, double y);
	Individual(int stage, Species sp, double x, double y);


};
