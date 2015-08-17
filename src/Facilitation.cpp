#include"Species.hpp"


class ArenaFac : public Arena {
	int lifestages;
	double width, height;
	Species *stages;
	Species *facilitator;
	
	Arena(int lifestages, double **baserates, double **facilitation, double width, double height) :lifestages(lifestages),width(width),height(height) {
		int i;
		this.stages = malloc(num_stages*(sizeof(*Species)));

		for(i=0;i<lifestages;i++){
			stages[i] = new Species(baserates[i],facilitation[i]);
		}

		facilitator = new Species(baserates[i],NULL);

	}

	void populate(int *stagesinit, int facinit){
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

	int selectStage(){
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

	void turn() {
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

	void findFacilitator(double x, double y){
		return facilitator.isPresent(x,y);
	}

}







