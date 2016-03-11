
#include"Facilitation.hpp"
#include"Random.hpp"

unsigned long Individual::id_MAX = 0;

Individual::Individual(Arena *ar, Species *sp, double x, double y) : arena(ar), p(x,y), id(id_MAX++) {
	unsigned int i;
	spnum = arena->getSpNum();
	affectingNeighbours = (std::list<Individual*>*) malloc(spnum*sizeof(std::list<Individual*> ));
	affectedNeighbours = (std::list<Individual*>*) malloc(spnum*sizeof(std::list<Individual*> ));
	for(i=0;i<spnum;i++){
		affectingNeighbours[i] = {};
		affectedNeighbours[i] = {};
	}
	setSpecies(sp);
}
/*TODO: this function is a copy from the above.  there has to be a way to just call one constructor from the other >.< */
Individual::Individual(Arena *ar, Species *sp, Position p) : arena(ar), p(p), id(id_MAX++){
	unsigned int i;
	spnum = arena->getSpNum();
	affectingNeighbours = (std::list<Individual*>*) malloc(spnum*sizeof(std::list<Individual*> ));
	affectedNeighbours = (std::list<Individual*>*) malloc(spnum*sizeof(std::list<Individual*> ));
	for(i=0;i<spnum;i++){
		affectingNeighbours[i] = {};
		affectedNeighbours[i] = {};
	}
	setSpecies(sp);
}

void	Individual::setSpecies(Species *sp) {
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

double Individual::actualD(){
	unsigned int sp;
	double actuald=D,effect;
	for(sp = 0; sp < spnum; sp++){
		if((effect = species->getInteraction(sp)) != 0 && affectingNeighbours[sp].empty()){
			actuald -= effect;
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
	/* NOTE: on changing this type please change the typedef on Facilitation.hpp */
	status_line ret  = {species->getId(),id,p.x,p.y};
	return ret;
}

void 	Individual::grow(){
	species->remove(this->ref);
	setSpecies(species->getNextStage());
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
	unsigned int sp;
	std::list<Individual*>::iterator i;
	for(sp = 0; sp < spnum; sp++){
		if(!affectingNeighbours[sp].empty()){
			for(i=affectingNeighbours[sp].begin();i!=affectingNeighbours[sp].end();i = affectingNeighbours[sp].erase(i)){
				(*i)->removeAffectedNeighbour(this);
			}
		}

		if(!affectedNeighbours[sp].empty()){
			for(i=affectedNeighbours[sp].begin();i!=affectedNeighbours[sp].end();i = affectedNeighbours[sp].erase(i)){
				(*i)->removeAffectingNeighbour(this);
			}
		}
	}
}

void Individual::initNeighbours(){
	unsigned int s;
	clearNeighbours();
	for(s=0;s<spnum;s++){
		if(species->getInteraction(s) != 0){
			addAffectingNeighbourList(arena->getPresent(s,p));
		}
	}

	arena->addAffected(this);
}

void Individual::addAffectedNeighbourList(std::list<Individual*> neighList){
	std::list<Individual*>::iterator i;

	for(i=neighList.begin();i!=neighList.end();i++){
		addAffectedNeighbour(*i);
		/* makes sure that your neighbours adds you too */
		(*i)->addAffectingNeighbour(this);
	}
}

void Individual::addAffectingNeighbourList(std::list<Individual*> neighList){
	std::list<Individual*>::iterator i;

	for(i=neighList.begin();i!=neighList.end();i++){
		addAffectingNeighbour(*i);
		/* makes sure that your neighbours adds you too */
		(*i)->addAffectedNeighbour(this);
	}
}

void 	Individual::addAffectedNeighbour(Individual *i){
	int s = i->getSpeciesId();
	affectedNeighbours[s].push_back(i);
}

void 	Individual::addAffectingNeighbour(Individual *i){
	int s = i->getSpeciesId();
	affectingNeighbours[s].push_back(i);
}

void 	Individual::removeAffectedNeighbour(Individual *i){
	int s = i->getSpeciesId();
	affectedNeighbours[s].remove(i);
}

void 	Individual::removeAffectingNeighbour(Individual *i){
	int s = i->getSpeciesId();
	affectingNeighbours[s].remove(i);
}

bool 	Individual::noAffectingNeighbours(int i){
	return affectingNeighbours[i].empty();
}
