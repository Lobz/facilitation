
#include"Facilitation.hpp"
#include"Random.hpp"

unsigned long Individual::id_MAX = 0;

Individual::Individual(Arena *ar, Species *sp, double x, double y):Individual(ar,sp,Position(x,y)){} 


Individual::Individual(Arena *ar, Species *sp, Position pos) : arena(ar), id(id_MAX++), 
	affectingMeNeighbours(ar->getSpNum()+1), affectedByMeNeighbours(ar->getSpNum()+1) {

	p = ar->boundaryCondition(pos), 
	spnum = arena->getSpNum();
	setSpecies(sp);
	info  = new IndividualStatus(sp->getId(),id,p.x,p.y,arena->getTotalTime());
	if(p.x==-1) die();
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

Individual::~Individual(){
	info->addToHistory(arena);
	clearNeighbours();
	delete(info);
}


int 		Individual::getSpeciesId(){return species->getId();}
Position 	Individual::getPosition(){return p;}
double 		Individual::getRadius(){return Rad;}
const unsigned long Individual::getId(){return id;}

double Individual::actualD(){
	int sp;
	double actuald=D,effect;
	for(sp = 1; sp <= spnum; sp++){
		if((effect = species->getInteraction(sp)) != 0 && !affectingMeNeighbours[sp].empty()){
			actuald -= effect*affectingMeNeighbours[sp].size(); /* note that effect is LINEAR on number of affecting neighbours */
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

void 	Individual::grow(){
	species->remove(this->ref);
	setSpecies(species->getNextStage()); /* note: setSpecies clears and re-inits the neighbours */
	info->setGrowth(arena->getTotalTime());
}

void	Individual::reproduce(){
	//std::cout << "disperseIndividual called with p=(" << p.x <<","<<p.y<<")\n";
	seedStage->disperseIndividual(p);
}

void 	Individual::die(){
	species->remove(this->ref);
	info->setDeath(arena->getTotalTime());
	clearNeighbours();
	delete(this);
}

void 	Individual::clearNeighbours(){
	int sp;
	std::list<Individual*>::iterator i;
	for(sp = 1; sp <= spnum; sp++){
		for(i=affectingMeNeighbours[sp].begin();i!=affectingMeNeighbours[sp].end();i = affectingMeNeighbours[sp].erase(i)){
			(*i)->removeAffectedByMeNeighbour(this);
		}

		for(i=affectedByMeNeighbours[sp].begin();i!=affectedByMeNeighbours[sp].end();i = affectedByMeNeighbours[sp].erase(i)){
			(*i)->removeAffectingMeNeighbour(this);
		}
	}
}

void Individual::initNeighbours(){
	int s;
	for(s=1;s<=spnum;s++){
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
	affectedByMeNeighbours[s].push_back(i);
}

void 	Individual::addAffectingMeNeighbour(Individual *i){
	int s = i->getSpeciesId();
	if(i==this){return;}
	affectingMeNeighbours[s].push_back(i);
}

void 	Individual::removeAffectedByMeNeighbour(Individual *i){
	int s = i->getSpeciesId();
	affectedByMeNeighbours[s].remove(i);
}

void 	Individual::removeAffectingMeNeighbour(Individual *i){
	int s = i->getSpeciesId();
	affectingMeNeighbours[s].remove(i);
}

bool 	Individual::noAffectingMeNeighbours(int i){
	return affectingMeNeighbours[i].empty();
}

IndividualStatus::IndividualStatus(int sp, unsigned long pid, double px, double py, double ctime):initialSp(sp),id(pid),x(px),y(py),creationTime(ctime),deathTime(-1){
	growthTimes = {};
}
void IndividualStatus::setGrowth(double time){ growthTimes.push_back(time); }
void IndividualStatus::setDeath(double time){ deathTime=time; }

void IndividualStatus::addToHistory(Arena *ar){
	std::list<double>::iterator i;
	double time1=creationTime,time2;
	int sp = initialSp;
	for(i = growthTimes.begin(); i!=growthTimes.end();i++){
		time2 = *i;
		ar->addToHistory(sp,id,x,y,time1,time2);
		time1 = time2;
		sp++;
	}
	ar->addToHistory(sp,id,x,y,time1,deathTime);
}
