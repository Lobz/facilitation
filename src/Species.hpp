#ifndef SPECIES_H
#define SPECIES_H

#include"Arena.hpp"

class Species {
	private:
	int id;
	int spnum, kernelType;
	double G, R, D, Rad, dispersalRadius, maxStressEffect, interactionVariation;
	double totalRate;

	Arena *arena;
	std::list<Individual*> population;
	Species *nextStage, *seedStage;
	/* array of interaction coeficients (affecting deathrate) */
	double *interactions;

	public:
	Species(Arena *ar,int id, double *par);
	Species(Arena *ar,int id, double D, double G, double R, double Rad, double maxStressEffect);
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
	void setInteractionVariation(double maxeffect);



	/* GETS */
	double getTotalRate();
	double getG();
	double getR();
	double getD(Position p);
	double getRad();
	double getInteraction(int species_id,Position p);
	int getId();
	Species* getNextStage();
	Species* getSeedStage();

	int getAbundance();
	void print(double time);
};
#endif
