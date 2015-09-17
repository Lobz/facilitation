#include<list>
#include<cstdlib>
#include<iostream>
#include"Position.hpp"

#ifndef FACILITATION_H
#define FACILITATON_H

class Species;
class Individual;

class Arena {
	private:
	int lifestages,spnum;
	double width, height;
	double totalRate, *ratesList, totalTime;
	Species **stages;
	Species *facilitator;

	public:
	Arena(int lifestages, double **baserates, double facilitation, double width, double height);
	void populate(int *stagesinit);
	bool turn();
	bool findFacilitator(Position p);
	void print();

};

class Species {
	protected:
	int id;
	double G, R, D, Rad, facilitation;
	double totalRate;

	Arena *arena;
	std::list<Individual*> population;
	Species *nextStage, *seedStage;

	public:
	Species(Arena *ar,int id,double *par);
	void setFacilitation(double f);

	double getTotalRate();
	double getG();
	double getR();
	double getD(Position p);
	double getRad();
	Species* getNextStage();
	Species* getSeedStage();

	bool isPresent(Position p);
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
};


class Individual {
	private:
	static unsigned long id_MAX;
	Position p;
	const unsigned long id;
	double R, D, G, Rad, SqRad;
	double totalRate;
	Species *species, *seedStage;
	std::list<Individual*>::iterator ref;

	public:
	Individual(Species *sp, Position p);
	Individual(Species *sp, double x, double y);
	double getTotalRate();
	bool isPresent(Position p);
	void print();
	void act();

	private:
	void setSpecies(Species *sp);
	void grow();
	void reproduce();
	void die();

};




#endif
