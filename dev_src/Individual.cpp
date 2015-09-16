
#include"Facilitation.hpp"
#include"Random.hpp"

	Individual::Individual(Species *sp, double x, double y) :x(x), y(y) {
	setSpecies(sp);
}

void	Individual::setSpecies(Species *sp) {
	species = sp;
	G = species->getG();
	R = species->getR();
	D = species->getD(x,y);
	Rad = species->getRad();
	SqRad = Rad*Rad;
	seedStage = species->getSeedStage();
	ref = species->add(this);
}

double Individual::getTotalRate(){

	D = species->getD(x,y);
	return G+R+D;
}

bool   Individual::isPresent(double x2, double y2){
	if((x-x2)*(x-x2) + (y-y2)*(y-y2) < SqRad) return true;
	else return false;
}

void   Individual::act(){
	double r = Random(G+R+D);
	if(r < G) grow();
	else if (r < G+R) reproduce();
	else die();

	/* Print when acting */
	std::cout << "Acting: ";
	print();
}

void Individual::print(){
	std::cout <<  " in " << x << "," << y << "\n";
}

void 	Individual::grow(){
	species->remove(this->ref);
	setSpecies(species->getNextStage());
}

void	Individual::reproduce(){
	seedStage->addIndividual(x,y);
}

void 	Individual::die(){
	species->remove(this->ref);
	delete(this);
}



