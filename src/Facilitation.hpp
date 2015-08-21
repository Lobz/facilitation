#include"Species.hpp"


class Arena {
	int lifestages;
	double width, height;
	Species *stages;
	Species *facilitator;

	private:
	int selectStage();
	
	public:
	Arena(int lifestages, double **baserates, double facilitation, double width, double height) :lifestages(lifestages),width(width),height(height);
	void populate(int *stagesinit, int facinit);
	void turn();
	bool findFacilitator(double x, double y);

}

class Species {
	protected:
	double G, R, S, Rad, facilitation;

	Arena arena;
	DLL population;
	Species nextStage = NULL, seedStage;

	Species(Arena ar,double *par);
	void setFacilitation(double f);

	double getTotalRate();
	double getG();
	double getR();
	double getS(double x, double y);
	double getRad();
	Species getNextStage();
	Species getSeedStage();

	bool isPresent(double x, double y);
	void addIndividual(double x, double y);
	void act();

	void setNextStage(Species st);
	void setSeedStage();

	void remove(Individual i);
	void add(Individual i);

};


class Individual {
	protected:
	int lifestage;
	double R, S, G, lambda, x, y;
	Species species;

	public:
	Individual(Species sp, double x, double y);
	double getTotalRate();
	bool isPresent(double x, double y);
	void act();

	private:
	void setCharacters();
	void grow();
	void reproduce();
	void die();

};





