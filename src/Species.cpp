#include"Facilitation.hpp"
#include"Random.hpp"
#include<cstdio>



Species::Species(Arena *ar,int id, double *par) : Species(ar,id,par[2],par[0],par[1],par[3],0.5){}

Species::Species(Arena *ar,int id, double D, double G, double R=0, double Rad=0,double dispersalRadius=0)
:id(id),G(G),D(D),R(R),Rad(Rad),dispersalRadius(dispersalRadius){
	facilitation = 0;
	nextStage = NULL;
	seedStage = NULL;
	dispersalRadius = 0.5;

	arena = ar;

	std::cout << id << ": G=" << G << " , R=" << R << " , D=" << D << "\n";
}

void Species::setFacilitation(double f){
	if(facilitation > D){
		printf("WARNING: facilitation parameter set to be bigger than deathrate. Id = %d. Parameters G=%f,R=%f,D=%f,Rad=%f\n,facilitation=%d", id,G,R,D,Rad,facilitation);
	}
	facilitation = f;
}

void Species::addIndividual(double x, double y){
	if(G > 0 && nextStage==NULL) {
		printf("WARNING: Next stage set to NULL but G > 0. Check input data. Id = %d. Parameters G=%f,R=%f,D=%f,Rad=%f\n", id,G,R,D,Rad);
		throw id;
	}
	if(R > 0 && seedStage==NULL) {
		printf("WARNING: Seed stage set to NULL but R > 0. Check input data. Id = %d. Parameters G=%f,R=%f,D=%f,Rad=%f\n", id,G,R,D,Rad);
		throw id;
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
	Position p(Normal(0,dispersalRadius),Normal(0,dispersalRadius));
	return p;
}

double Species::getTotalRate(){
	totalRate = 0;
	std::list<Individual*>::iterator i;

	if(facilitation>0){
		for(i=population.begin();i!=population.end();i++){
			totalRate += (*i)->getTotalRate();
		}
	}
	else {
		totalRate = (G+R+D)*getAbundance();
	}

	return totalRate;
}

bool Species::isPresent(Position p, double radius) {
	std::list<Individual*>::iterator i;

	for(i=population.begin();i!=population.end();i++){
		if((*i)->isPresent(p,radius*radius)) return true;
	}

	return false;
}

std::list<Individual*> Species::getFacilitators(Position p){
	return arena->getFacilitators(p);
}

std::list<Individual*> Species::getPresent(Position p, double radius){
	std::list<Individual*>::iterator i;
	std::list<Individual*> list;

	for(i=population.begin();i!=population.end();i++){
		if((*i)->isPresent(p,radius*radius)) list.push_back(*i);
	}

	return list;
}

void Species::act(){
	std::list<Individual*>::iterator i;
	double r = Random(totalRate);
	//std::cout << "species selected. - sp=" << id << ", time=" << arena->getTotalTime() << ", size=" << population.size()<< ", r= " << r << "\n";

	for(i=population.begin();i!=population.end();i++){
		r -= (*i)->getTotalRate();
		if(r < 0) {
			(*i)->act();
			return;
		}
	}
	/* if the below code is executed, it's becase no individual was selected */
	std::cout << "WARNING: no individual selected. - sp=" << id << "\n";
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
double Species::getFac(){return facilitation;}
unsigned int Species::getId(){return id;}
double Species::getD(Position p){
	return D;
}

void Species::print(double time){
	std::list<Individual*>::iterator i;

	std::cout << "#" << population.size() << "\n";

	for(i=population.begin();i!=population.end();i++){
		std::cout << time << "," << id << ",";
		(*i)->print();
	}
}

status_list Species::getStatus(double time){
	status_list status;
	status_line line;
	std::list<Individual*>::iterator i;

	for(i=population.begin();i!=population.end();i++){
		line = (*i)->getStatus();
		line.push_front(time);
		status.push_front(line);
	}
	return status;
}
	
double Species::getAbundance(){
	return population.size();
}
