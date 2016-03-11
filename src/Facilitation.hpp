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
	Species **species;
	Species *facilitator;
	int bcond;

	public:
	Arena(int lifestages, double * baserates, double * facilitation, double width, double height, int bcond);

	/* high level functions */
	bool populate(int *stagesinit);
	bool turn();

	/* acessors for Species and Individuals */
	bool findPresent(unsigned int species_id, Position p);
	std::list<Individual*> getPresent(unsigned int species_id, Position p);
	void addAffected(Individual *ind);

	Position boundaryCondition(Position p);

	/* output functions */
	status_list getStatus();
	unsigned int getSpNum();
	double* getAbundance();
	double getTotalTime();
	void print();
};

class Species {
	private:
	unsigned int id;
	unsigned int spnum;
	double G, R, D, Rad, dispersalRadius;
	double totalRate;

	Arena *arena;
	std::list<Individual*> population;
	Species *nextStage, *seedStage;
	/* array of interaction coeficients (affecting deathrate) */
	double *interactions;

	public:
	Species(Arena *ar,int id, double *par);
	Species(Arena *ar,int id, double D, double G, double R, double Rad,double dispersalRadius);
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
	void setSeedStage(Species *st);
	void setFacilitation(double f);
	void setInteraction(unsigned int s, double effect);
	void setAutoInteraction(double effect);



	/* GETS */
	double getTotalRate();
	double getG();
	double getR();
	double getD(Position p);
	double getRad();
	double getInteraction(unsigned int species_id);
	unsigned int getId();
	Species* getNextStage();
	Species* getSeedStage();

	status_list getStatus(double time);
	double getAbundance();
	void print(double time);
};


class Individual {
	private:
	static unsigned long id_MAX;
	Position p;
	const unsigned long id;
	unsigned int spnum;
	double R, D, G, Rad, SqRad, facilitation;
	double actualD();
	double totalRate;
	Species *species, *seedStage;
	Arena *arena;
	std::list<Individual*>::iterator ref;
	/* array of lists of neighbours by species */
	std::vector<std::list<Individual*>> affectingNeighbours;
	std::vector<std::list<Individual*>> affectedNeighbours;
	void initNeighbours();

	public:
	Individual(Arena *ar, Species *sp, Position p);
	Individual(Arena *ar, Species *sp, double x, double y);
	/* general action function */
	void act();

	/* GETS */
	double getTotalRate();
	int getSpeciesId();
	Position getPosition();
	double getRadius();
	bool isPresent(Position p, double radius = 0);
	void print();
	status_line getStatus();



	/* INTERACTIONS */
	/** adds a neighbour list and cross-adds yourself to everyone in that list */
	void addAffectingNeighbourList(std::list<Individual*> neighList);
	/** adds a neighbour to the list. Don't forget to add cross-reference to neighbour's list! */
	void addAffectingNeighbour(Individual *i);
	/** removes neighbour from list. Doesn't remove cross-reference from neighbour's list */
	void removeAffectingNeighbour(Individual *i);
	/** adds a neighbour list and cross-adds yourself to everyone in that list */
	void addAffectedNeighbourList(std::list<Individual*> neighList);
	/** adds a neighbour to the list. Don't forget to add cross-reference to neighbour's list! */
	void addAffectedNeighbour(Individual *i);
	/** removes neighbour from list. Doesn't remove cross-reference from neighbour's list */
	void removeAffectedNeighbour(Individual *i);
	/** removes all neighbours */
	void clearNeighbours();
	bool noAffectingNeighbours(int i);
	

	private:
	void setSpecies(Species *sp);
	void grow();
	void reproduce();
	void die();

};




#endif
