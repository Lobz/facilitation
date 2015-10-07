#include"Facilitation.hpp"
#include"Random.hpp"

Arena::Arena(int lifestages, double **parameters, double facilitation, double width, double height) :lifestages(lifestages),spnum(lifestages+1),width(width),height(height) {
	int i;
	stages = (Species**)malloc(spnum*(sizeof(Species*)));
	ratesList = (double*)malloc(spnum*(sizeof(double)));

	for(i=0;i<spnum;i++){
		stages[i] = new Species(this,i,parameters[i]);
	}
	facilitator = stages[lifestages];

	for(i=0;i<lifestages-1;i++){
		stages[i]->setNextStage(stages[i+1]);
		stages[i]->setSeedStage(stages[0]);
	}
	stages[i]->setSeedStage(stages[0]);

	stages[0]->setFacilitation(facilitation);

	totalTime = 0.0;

}

void Arena::populate(int *stagesinit){
	int i,j;

	for(i=0;i<spnum;i++){
		for(j=0;j<stagesinit[i];j++){
			stages[i]->addIndividual(Random(width),Random(height));
		}
	}
}

bool Arena::turn() {
	int i;
	double r, time;

	totalRate = 0;
	for(i=0;i<spnum;i++){
		ratesList[i] =  stages[i]->getTotalRate();
		totalRate += ratesList[i];
	}

	if(totalRate == 0) {
		std::cout << "#This simulation has reached a stable state (totalRate = 0).\n";
		return false;
	}

	time = Exponential(totalRate);
	totalTime += time;

	/* select stage to act */
	r = Random(totalRate);
	for(i=0;i<spnum-1;i++){
		r -= ratesList[i];
		if(r < 0){
			break;
		}
	}
	stages[i]->act();
	return true;

}

bool Arena::findFacilitator(Position p){
	return facilitator->isPresent(p);
}

void Arena::print(){
	int i;
	std::cout 	<< "\n#Current status:\n#Time: " << totalTime;
	for(i=0;i<lifestages;i++){
		std::cout << "\n#Stage " << i << ":\n";
		stages[i]->print(totalTime);
	}
	std::cout << "\n#Facilitators:\n";
	facilitator->print(totalTime);
}

status_list Arena::getStatus(){
	int i;
	status_list status;
	for(i=0;i<spnum;i++){
		status.splice(status.end(),stages[i]->getStatus(totalTime));
	}
	return status;
}
