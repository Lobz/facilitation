#include"Facilitation.hpp"
#include"Random.cpp"

/***********/

	// [[Rcpp::export]]
Arena::Arena(int lifestages, double **parameters, double facilitation, double width, double height) :lifestages(lifestages),width(width),height(height) {
	int i;
	stages = (Species**)malloc(lifestages*(sizeof(Species*)));
	ratesList = (double*)malloc(lifestages*(sizeof(double)));

	for(i=0;i<lifestages;i++){
		stages[i] = new Species(this,parameters[i]);
	}

	for(i=0;i<lifestages-1;i++){
		stages[i]->setNextStage(stages[i]);
		stages[i]->setSeedStage(stages[0]);
	}

	stages[0]->setFacilitation(facilitation);

	facilitator = new Species(this,parameters[i]);


}

void Arena::populate(int *stagesinit){
	int i,j;

	for(i=0;i<lifestages;i++){
		for(j=0;j<stagesinit[i];j++){
			stages[i]->addIndividual(Random(width),Random(height));
		}
	}

	for(j=0;j<stagesinit[i];j++){
		facilitator->addIndividual(Random(width),Random(height));
	}
}

void Arena::turn() {
	int i;
	double r, time;

	totalRate = 0;
	for(i=0;i<lifestages;i++){
		ratesList[i] =  stages[i]->getTotalRate();
	}

	time = Exponential(totalRate);
	totalTime += time;

	/* select stage to act */
	r = Random(totalRate);
	for(i=0;i<lifestages-1;i++){
		r -= ratesList[i];
		if(r < 0){
			break;
		}
	}
	stages[i]->act();

}

bool Arena::findFacilitator(double x, double y){
	return facilitator->isPresent(x,y);
}

void Arena::print(){
	int i;
	std::cout 	<< "Current status:\nTime: " << totalTime;
	for(i=0;i<lifestages;i++){
		std::cout << "\nStage " << i << ":\n";
		stages[i]->print();
	}
	std::cout << "\nFacilitators:\n";
	facilitator->print();
}

/************/



Species::Species(Arena *ar, double *par){
	G = par[0];
	R = par[1];
	S = par[2];
	Rad = par[3];
	facilitation = 0;
	nextStage = NULL;
	seedStage = NULL;

	arena = ar;

}

void Species::setFacilitation(double f){
	facilitation = f;
}

void Species::addIndividual(double x, double y){
	/*Individual *i =*/ new Individual(this,x,y);
}

double Species::getTotalRate(){
	double trate = 0;
	std::list<Individual*>::iterator i;

	for(i=population.begin();i!=population.end();i++){
		trate += (*i)->getTotalRate();
	}

	return trate;
}

bool Species::isPresent(double x, double y){
	std::list<Individual*>::iterator i;

	for(i=population.begin();i!=population.end();i++){
		if((*i)->isPresent(x,y)) return true;
	}

	return false;
}

void Species::act(){
	std::list<Individual*>::iterator i;
	double r = Random(totalRate);

	for(i=population.begin();i!=population.end();i++){
		r -= (*i)->getTotalRate();
		if(r < 0) {
			(*i)->act();
			return;
		}
	}
}

void Species::setNextStage(Species *st) {nextStage = st;}
void Species::setSeedStage(Species *st) {seedStage = st;}


void Species::remove(std::list<Individual*>::iterator i){
	population.erase(i);
}

std::list<Individual*>::iterator Species::add(Individual *i){
	population.push_front(i);
	return population.begin();
}

Species* Species::getSeedStage() {return seedStage;}
Species* Species::getNextStage() {return nextStage;}
double Species::getG(){return G;}
double Species::getR(){return R;}
double Species::getRad(){return Rad;}
double Species::getS(double x, double y){
	if(facilitation != 0 && arena->findFacilitator(x,y)){
		return S+facilitation;
	}
	else return S;
}

void Species::print(){
	std::list<Individual*>::iterator i;

	std::cout << population.size() << "\n";

	for(i=population.begin();i!=population.end();i++){
		(*i)->print();
	}
}

/******************/

Individual::Individual(Species *sp, double x, double y) :x(x), y(y) {
	setSpecies(sp);
}

void	Individual::setSpecies(Species *sp) {
	species = sp;
	G = species->getG();
	R = species->getR();
	S = species->getS(x,y);
	Rad = species->getRad();
	SqRad = Rad*Rad;
	seedStage = species->getSeedStage();
	ref = species->add(this);
}

double Individual::getTotalRate(){

	S = species->getS(x,y);
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

	/* Print when acting */
	std::cout << "Acting: ";
	print();
}

void Individual::print(){
	std::cout <<  " in " << x << "," << y << "\n";
}

void 	Individual::grow(){
	species->remove(this->ref);
	setSpecies(species->getNextStage());
}

void	Individual::reproduce(){
	seedStage->addIndividual(x,y);
}

void 	Individual::die(){
	species->remove(this->ref);
	delete(this);
}



