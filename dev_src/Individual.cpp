
#include"Facilitation.hpp"
#include"Random.hpp"

	Individual::Individual(Species *sp, double x, double y) : p(x,y){
		setSpecies(sp);
	}
	Individual::Individual(Species *sp, Position p) : p(p){
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
}

double Individual::getTotalRate(){

	D = species->getD(p);
	return G+R+D;
}

bool   Individual::isPresent(Position p2){
	p2 -= p;
	if((p2.x)*(p2.x) + (p2.y)*(p2.y) < SqRad) return true;
	else return false;
}

void   Individual::act(){
	double r = Random(G+R+D);
	if(r < G) grow();
	else if (r < G+R) reproduce();
	else die();
}

void Individual::print(){
	std::cout <<  ", " << p.x << "," << p.y << "\n";
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
	delete(this);
}



