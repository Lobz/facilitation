#include<list>
#include<cstdlib>
#include<iostream>
#include<array>
#include"Position.hpp"
#include<Rcpp.h>

#ifndef FACILITATION_H
#define FACILITATON_H
#define FACILITATION_NUMPARAMETERS 4

class Species;
class Individual;

typedef std::list<double> status_line;
typedef std::list<status_line> status_list;

class Arena {
	private:
	int lifestages,spnum;
	double width, height;
	double totalRate, *ratesList, totalTime;
	Species **stages;
	Species *facilitator;

	public:
	Arena(int lifestages, double * baserates, double facilitation, double width, double height);
	bool populate(int *stagesinit);
	bool turn();
	bool findFacilitator(Position p);
	std::list<Individual*> getFacilitators(Position p);
	void print();

	status_list getStatus();
	double* getAbundance();
	double getTotalTime();
};

class Species {
	private:
	unsigned int id;
	double G, R, D, Rad, facilitation, dispersalRadius;
	double totalRate;

	Arena *arena;
	std::list<Individual*> population;
	Species *nextStage, *seedStage;

	public:
	Species(Arena *ar,int id, double *par);
	Species(Arena *ar,int id, double D, double G, double R, double Rad,double dispersalRadius);
	void setFacilitation(double f);

	double getTotalRate();
	double getG();
	double getR();
	double getD(Position p);
	double getRad();
	double getFac();
	unsigned int getId();
	Species* getNextStage();
	Species* getSeedStage();

	bool isPresent(Position p);
	std::list<Individual*> getFacilitators(Position p);
	std::list<Individual*> getPresent(Position p);
	void addIndividual(double x, double y);
	void addIndividual(Position p);	
	void disperseIndividual(double x, double y);
	void disperseIndividual(Position p);	
	Position dispersalKernel();
	void act();

	void setNextStage(Species *st);
	void setSeedStage(Species *st);

	void remove(std::list<Individual*>::iterator i);
	std::list<Individual*>::iterator add(Individual *i);

	void print(double time);

	status_list getStatus(double time);
	double getAbundance();
};


class Individual {
	private:
	static unsigned long id_MAX;
	Position p;
	const unsigned long id;
	double R, D, G, Rad, SqRad, facilitation;
	double totalRate;
	Species *species, *seedStage;
	std::list<Individual*>::iterator ref;
	std::list<Individual*> neighbours;
	void initNeighbours();

	public:
	Individual(Species *sp, Position p);
	Individual(Species *sp, double x, double y);
	double getTotalRate();
	bool isPresent(Position p);
	void print();
	void act();
	void addNeighbour(Individual *i);
	void removeNeighbour(Individual *i);
	
	status_line getStatus();

	private:
	void setSpecies(Species *sp);
	void grow();
	void reproduce();
	void die();

};




#endif
