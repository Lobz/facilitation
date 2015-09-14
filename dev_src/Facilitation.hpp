#include<list>
#include<cstdlib>
#include<iostream>

class Species;
class Individual;

class Arena {
	private:
	int lifestages;
	double width, height;
	double totalRate, *ratesList, totalTime;
	Species **stages;
	Species *facilitator;

	public:
	Arena(int lifestages, double **baserates, double facilitation, double width, double height);
	void populate(int *stagesinit);
	void turn();
	bool findFacilitator(double x, double y);
	void print();

};

class Species {
	protected:
	int id;
	double G, R, S, Rad, facilitation;
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
	double getS(double x, double y);
	double getRad();
	Species* getNextStage();
	Species* getSeedStage();

	bool isPresent(double x, double y);
	void addIndividual(double x, double y);
	void act();

	void setNextStage(Species *st);
	void setSeedStage(Species *st);

	void remove(std::list<Individual*>::iterator i);
	std::list<Individual*>::iterator add(Individual *i);

	void print();
};


class Individual {
	private:
	double R, S, G, x, y, Rad, SqRad;
	double totalRate;
	int id;
	Species *species, *seedStage;
	std::list<Individual*>::iterator ref;

	public:
	Individual(Species *sp, double x, double y);
	double getTotalRate();
	bool isPresent(double x, double y);
	void print();
	void act();

	private:
	void setSpecies(Species *sp);
	void grow();
	void reproduce();
	void die();

};





