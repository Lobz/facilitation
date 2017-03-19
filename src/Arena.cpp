#include"Individual.hpp"
#include"Random.hpp"

Arena::Arena(int maxspid, double *parameters, double w, double h, int bc) :maxsp(maxspid),width(w),height(h),bcond(bc) {
	int i;
	species = (Species**)malloc((1+maxsp)*(sizeof(Species*)));
	ratesList = (double*)malloc((1+maxsp)*(sizeof(double)));

	for(i=1;i<=maxsp;i++){
		species[i] = new Species(this,i,parameters+FACILITATION_NUMPARAMETERS*(i-1));
	}

	totalTime = 0.0;

	std::cout << "Arena " << width << "x" << height << " initialized with " << maxsp << " species.\n";

	history = new History();
}

void Arena::createStructuredSpecies(int minId, int maxId, double dispersal, int dkernel) {
	int i;

	for(i=minId;i<maxId;i++){
		species[i]->setNextStage(species[i+1]);
		species[i]->setSeedStage(species[minId], dispersal, dkernel);
	}
	// last stage doesn't have next stage
	species[i]->setSeedStage(species[1], dispersal, dkernel);
}

void Arena::createSimpleSpecies(int id, double dispersal, int dkernel){
	species[id]->setSeedStage(species[id], dispersal, dkernel);
}

History * Arena::finalStatus(){
	int i;
	for(i=1;i<=maxsp;i++){
		delete(species[i]);
	}
	free(species);
	free(ratesList);
	return history;
}

void Arena::setInteractions(double *interactions, double slope){
	int i,j;
	for(i=1;i<=maxsp;i++){
		species[i]->setInteractionVariation(slope);
		for(j=1;j<=maxsp;j++){
			species[i]->setInteraction(j,interactions[maxsp*(i-1)+(j-1)]);
		}
	}
}

bool Arena::populate(int *speciesinit){
	int i,j;

	for(i=1;i<=maxsp;i++){
		std::cout << "Starting to populate species " << i << " with " << speciesinit[i-1] << " individuals.\n";
		for(j=0;j<speciesinit[i-1];j++){
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
	for(i=1;i<=maxsp;i++){
		ratesList[i] =  species[i]->getTotalRate();
		totalRate += ratesList[i];
	}

	//std::cout << "TotalRate calculated at time=" << totalTime << "\n";

	if(totalRate < 0) {
		std::cout << "#This simulation has reached an impossible state (totalRate < 0).\n";
		for(i=1;i<=maxsp;i++){
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
	for(i=1;i<=maxsp-1;i++){
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
	for(i=1;i<=maxsp;i++){
		std::cout << "\n#Stage " << i << ":\n";
		species[i]->print(totalTime);
	}
}


/*TODO: should this array be dynamically allocated? */
int* Arena::getAbundance(){
	int i;
	int *ab;
	ab = (int*)malloc(maxsp*sizeof(int));
	for(i=1;i<=maxsp;i++){
		ab[i] = species[i]->getAbundance();
	}
	return ab;
}

int Arena::getTotalAbundance(){
	int i;
	int ab=0;
	for(i=1;i<=maxsp;i++){
		ab += species[i]->getAbundance();
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

	for(j=1;j<=maxsp;j++){
		if(species[j]->getInteraction(sp,p) != 0){
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
	return maxsp;
}

Position Arena::boundaryCondition(Position p){
	/*bool flag = false;
	if(p.x <0 || p.x > width || p.y <0 || p.y > height){
		flag = true;
		std::cout << "Applying boundary condition: P-original = (" << p.x << "," << p.y << "), ";
	}*/
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

		case(0):
			/* ABSORTIVE */
			if(p.x < 0 || p.x > width || p.y < 0 || p.y > height) { p.x = -1; p.y=-1; }
			break;
		default:
			std::cout << "Unsuported boundary condition\n";
			exit(1);
	}
//	if(flag)std::cout << "P-final = (" << p.x << "," << p.y << ")\n";

	return p;
}

void Arena::addToHistory(int sp, unsigned long id, double x, double y, double beginT, double endT){
	history->sp_list.push_back(sp);
	history->id_list.push_back(id);
	history->x_list.push_back(x);
	history->y_list.push_back(y);
	history->beginTime_list.push_back(beginT);
	history->endTime_list.push_back(endT);
}

double Arena::getStressValue(Position p){
	return p.x/width;
}
