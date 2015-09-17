#include"Facilitation.hpp"
#include"Random.hpp"



Species::Species(Arena *ar,int id, double *par):id(id){
	G = par[0];
	R = par[1];
	D = par[2];
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
	if(G > 0 && nextStage==NULL) {
		printf("WARNING: Next stage set to NULL but G > 0. Check input data. Id = %d. Parameters G=%f,R=%f,D=%f,Rad=%f\n", id,G,R,D,Rad);
		exit(1);
	}
	if(R > 0 && seedStage==NULL) {
		printf("WARNING: Seed stage set to NULL but R > 0. Check input data. Id = %d. Parameters G=%f,R=%f,D=%f,Rad=%f\n", id,G,R,D,Rad);
		exit(1);
	}
	/*Individual *i =*/ new Individual(this,x,y);
}

void Species::addIndividual(Position p){
	addIndividual(p.x,p.y);
}

void Species::disperseIndividual(double x, double y){
	Position p(x,y);
	disperseIndividual(p);
}
	
void Species::disperseIndividual(Position p){
	addIndividual(p + dispersalKernel());
}

Position Species::dispersalKernel(){
	Position p(Random(2) -1, Random(2) -1);
	return p;
}

double Species::getTotalRate(){
	double trate = 0;
	std::list<Individual*>::iterator i;

	for(i=population.begin();i!=population.end();i++){
		trate += (*i)->getTotalRate();
	}

	return trate;
}

bool Species::isPresent(Position p){
	std::list<Individual*>::iterator i;

	for(i=population.begin();i!=population.end();i++){
		if((*i)->isPresent(p)) return true;
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
double Species::getD(Position p){
	if(facilitation != 0 && arena->findFacilitator(p)){
		return D-facilitation;
	}
	else return D;
}

void Species::print(){
	std::list<Individual*>::iterator i;

	std::cout << population.size() << "\n";

	for(i=population.begin();i!=population.end();i++){
		std::cout << id;
		(*i)->print();
	}
}
