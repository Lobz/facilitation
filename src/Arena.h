#ifndef ARENA_H
#define ARENA_H
#define FACILITATION_NUMPARAMETERS 4

#include<list>
#include<cstdlib>
#include<iostream>
#include<array>
#include"Position.h"
#include<Rcpp.h>

class Species;
class Individual;

class History{
	public:
	std::list<int> sp_list;
	std::list<unsigned long> id_list;
	std::list<double> x_list;
	std::list<double> y_list;
	std::list<double> beginTime_list;
	std::list<double> endTime_list;
};

class Arena {
	private:
	int maxsp;
	double width, height;
	double totalRate, *ratesList, totalTime;
	Species **species;
	Species *facilitator;
	int bcond;
	History * history;

	public:
	Arena(int numsp, double * baserates, double width, double height, int bcond);

	/* high level functions */
	void createStructuredSpecies(int minId, int maxId, double dispersal, int dkernel);
	void createSimpleSpecies(int id, double dispersal, int dkernel);
	bool populate(int *stagesinit);
	bool turn();
	void setInteractions(double *interactions);

	/* acessors for Species and Individuals */
	bool findPresent(int species_id, Position p);
	std::list<Individual*> getPresent(int species_id, Position p);
	void addAffectedByMe(Individual *ind);

	Position boundaryCondition(Position p);

	void addToHistory(int sp, unsigned long id, double x, double y, double beginT, double endT);
	/* output functions */
	History * finalStatus();
	int getSpNum();
	int* getAbundance();
	int getTotalAbundance();
	double getTotalTime();
	double getWidth();
	double getHeight();
};

#endif
