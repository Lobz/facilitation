#include"Facilitation.hpp"
#include"Random.hpp"

Arena::Arena(int lifestages, double *parameters, double dispersal, double width, double height, int bcond, int dkernel) :lifestages(lifestages),spnum(lifestages+1),width(width),height(height),bcond(bcond) {
	int i;
	species = (Species**)malloc(spnum*(sizeof(Species*)));
	ratesList = (double*)malloc(spnum*(sizeof(double)));

	for(i=0;i<spnum;i++){
		species[i] = new Species(this,i,parameters+FACILITATION_NUMPARAMETERS*i);
	}
	facilitator = species[lifestages];

	for(i=0;i<lifestages-1;i++){
		species[i]->setNextStage(species[i+1]);
		species[i]->setSeedStage(species[0], dispersal, dkernel);
	}
	species[i]->setSeedStage(species[0], dispersal);
	species[i+1]->setSeedStage(species[i+1], dispersal);


	totalTime = 0.0;

	std::cout << "Arena initialized\n";

}

void Arena::setInteractions(double *interactions){
	int i,j;
	for(i=0;i<spnum;i++){
		for(j=0;j<spnum;j++){
			species[i]->setInteraction(j,interactions[spnum*i+j]);
		}
	}
}

bool Arena::populate(int *speciesinit){
	int i,j;

	for(i=0;i<spnum;i++){
		std::cout << "Starting to populate species " << i << "\n";
		for(j=0;j<speciesinit[i];j++){
			try{
				species[i]->addIndividual(Random(width),Random(height));
			}
			catch(int e){
				std::cout << "Unable to populate\n";
				return false;
			}
		}
	}
	return true;
}

bool Arena::turn() {
	int i;
	double r, time;

	totalRate = 0;
	for(i=0;i<spnum;i++){
		ratesList[i] =  species[i]->getTotalRate();
		totalRate += ratesList[i];
	}

	//std::cout << "TotalRate calculated at time=" << totalTime << "\n";

	if(totalRate < 0) {
		std::cout << "#This simulation has reached an impossible state (totalRate < 0).\n";
		for(i=0;i<spnum;i++){
			std::cout << "Species of id=" << i << " has totalRate=" << species[i]->getTotalRate() <<"\n";
		}
		return false;
	}

	if(totalRate == 0) {
		std::cout << "#This simulation has reached a stable state (totalRate = 0).\n";
		return false;
	}

	time = Exponential(totalRate);
	totalTime += time;

	//std::cout << "TotalTime calculated at time=" << totalTime << "\n";

	/* select stage to act */
	r = Random(totalRate);
	for(i=0;i<spnum-1;i++){
		r -= ratesList[i];
		if(r < 0){
			break;
		}
	}
	species[i]->act();
		
	//std::cout << "Species " << i << "acted at time=" << totalTime << "\n";

	return true;

}

void Arena::print(){
	int i;
	std::cout 	<< "\n#Current status:\n#Time: " << totalTime;
	for(i=0;i<lifestages;i++){
		std::cout << "\n#Stage " << i << ":\n";
		species[i]->print(totalTime);
	}
	std::cout << "\n#Facilitators:\n";
	facilitator->print(totalTime);
}

status_list Arena::getStatus(){
	int i;
	status_list status;
	for(i=0;i<spnum;i++){
		status.splice(status.end(),species[i]->getStatus(totalTime));
	}
	return status;
}

/*TODO: should this array be dynamically allocated? */
double* Arena::getAbundance(){
	int i;
	double *ab;
	ab = (double*)malloc(spnum*sizeof(double));
	for(i=0;i<spnum;i++){
		ab[i] = species[i]->getAbundance();
	}
	return ab;
}

bool Arena::findPresent(int species_id, Position p){
	return species[species_id]->isPresent(p);
}

std::list<Individual*> Arena::getPresent(int species_id,Position p){
	return species[species_id]->getPresent(p);
}

void Arena::addAffectedByMe(Individual *ind){
	int j;
	int sp = ind->getSpeciesId();
	Position p = ind->getPosition();
	double radius = ind->getRadius(); /* will look for inds within this radius of me */

	for(j=0;j<spnum;j++){
		if(species[j]->getInteraction(sp) != 0){
			ind->addAffectedByMeNeighbourList(species[j]->getPresent(p,radius));
		}
	}
}

double Arena::getTotalTime(){
	return totalTime;
}
double Arena::getWidth(){
	return width;
}
double Arena::getHeight(){
	return height;
}

int Arena::getSpNum(){
	return spnum;
}

Position Arena::boundaryCondition(Position p){
	switch(bcond){

		case(1):
			/* REFLEXIVE */
			while(p.x <0 || p.x > width){
				if(p.x < 0) p.x = -p.x;
				if(p.x > width) p.x = width - (p.x - width);
			}
			while(p.y <0 || p.y > height){
				if(p.y < 0) p.y = -p.y;
				if(p.y > height) p.y = height - (p.y - height);
			}
			break;

		case(2):
			/* PERIODIC */
			while(p.x < 0) p.x += width;
			while(p.x > width) p.x -= width;;
			while(p.y < 0) p.y += height;
			while(p.y > height) p.y -= height;;
			break;

		case(3):
			/* ABSORTIVE */
			if(p.x < 0 || p.x > width || p.y < 0 || p.y > height) p.x = -100;
			break;
	}

	return p;
}
