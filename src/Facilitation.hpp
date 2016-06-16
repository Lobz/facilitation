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
	int lifestages,spnum;
	double width, height;
	double totalRate, *ratesList, totalTime;
	Species **species;
	Species *facilitator;
	int bcond;
	History * history;

	public:
	Arena(int lifestages, double * baserates, double dispersal, double width, double height, int bcond, int dkernel);

	/* high level functions */
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
	void print();
};

class Species {
	private:
	int id;
	int spnum, kernelType;
	double G, R, D, Rad, dispersalRadius;
	double totalRate;

	Arena *arena;
	std::list<Individual*> population;
	Species *nextStage, *seedStage;
	/* array of interaction coeficients (affecting deathrate) */
	double *interactions;

	public:
	Species(Arena *ar,int id, double *par);
	Species(Arena *ar,int id, double D, double G, double R, double Rad);
	~Species();
	/* BASIC RUN ACTION */
	void act();

	/* INTERACTIONS */
	/* note: for the following functions, if radius is unspecified (=0), the radius used is the species own radius */
	bool isPresent(Position p, double radius = 0);
	std::list<Individual*> getPresent(Position p, double radius = 0);

	/* REPRODUCTION AND DEATH */
	std::list<Individual*>::iterator add(Individual *i);
	void remove(std::list<Individual*>::iterator i);
	void addIndividual(double x, double y);
	void addIndividual(Position p);	
	void disperseIndividual(double x, double y);
	void disperseIndividual(Position p);	
	Position dispersalKernel();


	/* SETS */
	void setNextStage(Species *st);
	void setSeedStage(Species *st, double dispersal, int kernel = 1);
	void setFacilitation(double f);
	void setInteraction(int s, double effect);
	void setAutoInteraction(double effect);



	/* GETS */
	double getTotalRate();
	double getG();
	double getR();
	double getD(Position p);
	double getRad();
	double getInteraction(int species_id);
	int getId();
	Species* getNextStage();
	Species* getSeedStage();

	int getAbundance();
	void print(double time);
};

/* INDIVIDUAL */

class IndividualStatus {
	public:
	int initialSp;
	unsigned long id;
	double x, y;
	
	double creationTime, deathTime;
	std::list<double> growthTimes;

	IndividualStatus(int sp, unsigned long id, double x, double y, double ctime);
	
	void setGrowth(double time);
	void setDeath(double time);

	void addToHistory(Arena *ar);
};


class Individual {
	private:
	static unsigned long id_MAX;
	Position p;
	const unsigned long id;
	int spnum;
	double R, D, G, Rad, SqRad, facilitation;
	double actualD();
	double totalRate;
	Species *species, *seedStage;
	Arena *arena;
	std::list<Individual*>::iterator ref;
	IndividualStatus *info;
	/* array of lists of neighbours by species */
	std::vector<std::list<Individual*>> affectingMeNeighbours;
	std::vector<std::list<Individual*>> affectedByMeNeighbours;
	void initNeighbours();

	public:
	Individual(Arena *ar, Species *sp, Position p);
	Individual(Arena *ar, Species *sp, double x, double y);
	/* general action function */
	void act();

	/* GETS */
	double getTotalRate();
	int getSpeciesId();
	const unsigned long getId();
	Position getPosition();
	double getRadius();
	bool isPresent(Position p, double radius = 0);
	void print();



	/* INTERACTIONS */
	/** adds a neighbour list and cross-adds yourself to everyone in that list */
	void addAffectingMeNeighbourList(std::list<Individual*> neighList);
	/** adds a neighbour to the list. Don't forget to add cross-reference to neighbour's list! */
	void addAffectingMeNeighbour(Individual *i);
	/** removes neighbour from list. Doesn't remove cross-reference from neighbour's list */
	void removeAffectingMeNeighbour(Individual *i);
	/** adds a neighbour list and cross-adds yourself to everyone in that list */
	void addAffectedByMeNeighbourList(std::list<Individual*> neighList);
	/** adds a neighbour to the list. Don't forget to add cross-reference to neighbour's list! */
	void addAffectedByMeNeighbour(Individual *i);
	/** removes neighbour from list. Doesn't remove cross-reference from neighbour's list */
	void removeAffectedByMeNeighbour(Individual *i);
	/** removes all neighbours */
	void clearNeighbours();
	bool noAffectingMeNeighbours(int i);
	
	~Individual();

	private:
	void setSpecies(Species *sp);
	void grow();
	void reproduce();
	void die();

};




#endif
