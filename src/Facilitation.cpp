#include"Facilitation.hpp"

/***********/

	Arena::Arena(int lifestages, double **parameters, double facilitation, double width, double height) :lifestages(lifestages),width(width),height(height) {
		int i;
		this.stages = malloc(num_stages*(sizeof(*Species)));

		for(i=0;i<lifestages;i++){
			stages[i] = new Species(this,parameters[i]);
		}

		for(i=0;i<lifestages-1;i++){
			stages[i].setNextStage(stages[j]);
			stages[i].setSeedState(stages[0]);
		}

		stages[0].setFacilitation(facilitation);

		facilitator = new Species(parameters[i]);

	}

	void Arena::populate(int *stagesinit, int facinit){
		int i,j;
		
		for(i=0;i<lifestages;i++){
			for(j=0;j<stagesinit[i];j++){
				stages[i].addIndividual(Random(width),Random(height));
			}
		}

		for(i=0;i<facinit;i++){
			facilitator.addIndividual(Random(width),Random(height));
		}
	}

	int Arena::selectStage(){
		int i;
		double r;

		r = Random(totalRate);

		for(i=0;i<lifestages-1;i++){
			if(r < ratesList[i]){
				return i;
			}
		}
		return i;
	}

	void Arena::turn() {
		int i;

		totalRate = 0;
		for(i=0;i<lifestages;i++){
			ratesList[i] = (totalRate += getTotalRate(stages[i]));
		}
		/*ratesList[i] = (totalRate += getTotalRate(facilitator));*/

		time = Exponential(totalRate);
		totalTime += time;

		stages[selectStage()].act();

	}

	void Arena::findFacilitator(double x, double y){
		return facilitator.isPresent(x,y);
	}

/************/



Species::Species(double *par, Arena ar){
	G = par[0];
	R = par[1];
	S = par[2];
	Rad = par[3];
	facilitation = 0;

	population = new Population();
	arena = ar;

}

void Species::setFacilitation(double f){
	facilitation = f;
}

void Species::addIndividual(double x, double y){
	population.push(new Individual(this,x,y));
}

double Species::getTotalRate(){
	double trate = 0;
	DLL pointer = population.head();

	while(pointer != NULL){
		trate += pointer.content.getTotalRate();
		pointer = pointer.next();
	}

	return trate;
}

bool Species::isPresent(double x, double y){
	DLL pointer = population.head();

	while(pointer != NULL){
		if(pointer.content.isPresent(x,y)) return true;
		pointer = pointer.next();
	}

	return false;
}

void Species::act(){
	DLL pointer = population.head();
	double r = Random(totalRate);

	while(pointer != NULL){

		pointer = pointer.next();
	}

	return false;
}

void Species::setNextStage(Species st) : nextStage(st);

Species Species::getNextStage() {
	return nextStage;
}

void Species::setSeedStage(Species st) : seedStage(st);

Species Species::getSeedStage() {
	return seedStage;
}

void Species::remove(Individual i){
	population.remove(i);
}

void Species::add(Individual i){
	population.push(i);
}



/******************/

	Individual::Individual(Species sp, double x, double y) : species(sp), x(x), y(y) {
		setCharacters();
	}

	Individual::setCharacters() {
		G = species.getG();
		R = species.getR();
		S = species.getS(x,y);
		Rad = species.getRad();
		SqRad = Rad*Rad;
		seedStage = species.getSeedStage()
	}

 double Individual.getTotalRate(){
		 
		S = sp.getS(x,y);
		return G+R+(1-S);
	}

 bool   Individual::isPresent(double x2, double y2){
		if((x-x2)*(x-x2) + (y-y2)*(y-y2) < SqRad) return true;
		else return false;
	}

 void   Individual::act(){
	 	double r = Random(G+R+(1-S));
		if(r < G) grow();
		else if (r < G+R) reproduce();
		else die();
	}
 
 void 	Individual::grow(){
		species.remove(this);
		species = species.getNextStage();
		species.add(this);
		setCharacters();
 	}

 void	Individual::reproduce(){
	 	seedStage.addIndividual(x,y);
 	}

 void 	Individual::die(){
	 	species.remove(this);
		delete(this);
 	}



