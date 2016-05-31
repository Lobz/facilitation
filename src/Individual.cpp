
#include"Facilitation.hpp"
#include"Random.hpp"

unsigned long Individual::id_MAX = 0;

Individual::Individual(Arena *ar, Species *sp, double x, double y):Individual(ar,sp,Position(x,y)){} 


Individual::Individual(Arena *ar, Species *sp, Position p) : arena(ar), p(ar->boundaryCondition(p)), id(id_MAX++), affectingNeighbours(ar->getSpNum()), affectedNeighbours(ar->getSpNum()) {
	spnum = arena->getSpNum();
	setSpecies(sp);
	if(p.x<0) die();
}

void	Individual::setSpecies(Species *sp) {
	clearNeighbours();

	species = sp;
	G = species->getG();
	R = species->getR();
	D = species->getD(p);
	Rad = species->getRad();
	SqRad = Rad*Rad;
	seedStage = species->getSeedStage();
	ref = species->add(this);

	initNeighbours();

}


int 		Individual::getSpeciesId(){return species->getId();}
Position 	Individual::getPosition(){return p;}
double 		Individual::getRadius(){return Rad;}
const unsigned long Individual::getId(){return id;}

double Individual::actualD(){
	int sp;
	double actuald=D,effect;
	for(sp = 0; sp < spnum; sp++){
		if((effect = species->getInteraction(sp)) != 0 && !affectingNeighbours[sp].empty()){
			actuald -= effect*affectingNeighbours[sp].size(); /* note that effect is LINEAR on number of affecting neighbours */
		}
	}
	if(actuald < 0) return 0;
	return actuald;
}

double Individual::getTotalRate(){

	return G+R+actualD();
}

bool   Individual::isPresent(Position p2, double sqRadius){
	if(sqRadius == 0) sqRadius = SqRad;
	p2 -= p;
	if((p2.x)*(p2.x) + (p2.y)*(p2.y) < sqRadius) return true;
	else return false;
}

void   Individual::act(){
	double r = Random(getTotalRate());

	//	std::cout << "sp=" << species->getId() << "\n";

	if(r < G) grow();
	else if (r < G+R) reproduce();
	else die();
}

void Individual::print(){
	std::cout << id <<  "," << p.x << "," << p.y << "\n";
}

status_line Individual::getStatus(){
	int i;
	/* NOTE: on changing this please change the typedef on Facilitation.hpp and the names on R/utils.R */
	status_line ret  = {species->getId(),id,p.x,p.y};
	for(i=0;i<spnum;i++){
		ret.push_back(affectingNeighbours[i].size());
	}
	for(i=0;i<spnum;i++){
		ret.push_back(affectedNeighbours[i].size());
	}
	return ret;
}

void 	Individual::grow(){
	species->remove(this->ref);
	setSpecies(species->getNextStage()); /* note: setSpecies clears and re-inits the neighbours */
}

void	Individual::reproduce(){
	seedStage->disperseIndividual(p);
}

void 	Individual::die(){
	species->remove(this->ref);
	clearNeighbours();
	delete(this);
}

void 	Individual::clearNeighbours(){
	int sp;
	std::list<Individual*>::iterator i;
	for(sp = 0; sp < spnum; sp++){
		for(i=affectingNeighbours[sp].begin();i!=affectingNeighbours[sp].end();i = affectingNeighbours[sp].erase(i)){
			(*i)->removeAffectedByMeNeighbour(this);
		}

		for(i=affectedNeighbours[sp].begin();i!=affectedNeighbours[sp].end();i = affectedNeighbours[sp].erase(i)){
			(*i)->removeAffectingMeNeighbour(this);
		}
	}
}

void Individual::initNeighbours(){
	int s;
	for(s=0;s<spnum;s++){
		if(species->getInteraction(s) != 0){
			/* do not use radius in looking for affecting neighbours, 
			 * effect radius is the affecting neighbour's radius */
			addAffectingMeNeighbourList(arena->getPresent(s,p));
		}
	}

	/* this function automatically uses my radius */
	arena->addAffectedByMe(this);
}

void Individual::addAffectedByMeNeighbourList(std::list<Individual*> neighList){
	std::list<Individual*>::iterator i;

	for(i=neighList.begin();i!=neighList.end();i++){
		addAffectedByMeNeighbour(*i);
		/* makes sure that your neighbours adds you too */
		(*i)->addAffectingMeNeighbour(this);
	}
}

void Individual::addAffectingMeNeighbourList(std::list<Individual*> neighList){
	std::list<Individual*>::iterator i;

	for(i=neighList.begin();i!=neighList.end();i++){
		addAffectingMeNeighbour(*i);
		/* makes sure that your neighbours adds you too */
		(*i)->addAffectedByMeNeighbour(this);
	}
}

void 	Individual::addAffectedByMeNeighbour(Individual *i){
	int s = i->getSpeciesId();
	if(i==this){return;}
	affectedNeighbours[s].push_back(i);
}

void 	Individual::addAffectingMeNeighbour(Individual *i){
	int s = i->getSpeciesId();
	if(i==this){return;}
	affectingNeighbours[s].push_back(i);
}

void 	Individual::removeAffectedByMeNeighbour(Individual *i){
	int s = i->getSpeciesId();
	affectedNeighbours[s].remove(i);
}

void 	Individual::removeAffectingMeNeighbour(Individual *i){
	int s = i->getSpeciesId();
	affectingNeighbours[s].remove(i);
}

bool 	Individual::noAffectingMeNeighbours(int i){
	return affectingNeighbours[i].empty();
}

