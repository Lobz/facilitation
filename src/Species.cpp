#include"Individual.h"
#include"Random.h"
#include<cstdio>

Species::Species(Arena *ar,int myid, double *par) : Species(ar,myid,par[0],par[1],par[2],par[3],par[4]){}

Species::Species(Arena *ar,int myid, double death, double growth, double rep=0, double radius=0, double maxEf=0)
    :id(myid),G(growth),D(death),R(rep),Rad(radius),maxStressEffect(maxEf)
{
    int i;
    nextStage = NULL;
    seedStage = NULL;
    dispersalRadius = 0;

    arena = ar;
    spnum = ar->getSpNum();

    interactions = (double*)malloc((spnum+1)*(sizeof(double)));
    interactions[0]=0; /* this is actually not used but let's set it to 0 just in case */
    for(i=1;i<=spnum;i++){
        interactions[i]=0;
    }
    interactionVariation=0;
}

Species::~Species(){
    /* clear population */
    std::list<Individual*>::iterator i;

    for(i=population.begin();i!=population.end();i++){
        delete(*i);
    }

    free(interactions);
}

void Species::setFacilitation(double f){setInteraction(spnum,f);}
void Species::setAutoInteraction(double effect){setInteraction(id,effect);}

void Species::setInteraction(int s, double effect){
    if(effect > D){
        Rcpp::warning("Interaction parameter set to be bigger than deathrate.");
    }
    interactions[s] = effect;
}

void Species::addIndividual(double x, double y){
    if(G > 0 && nextStage==NULL) {
        Rcpp::warning("Next stage set to NULL but G > 0. Check input data.");
        throw id;
    }
    if(R > 0 && seedStage==NULL) {
        Rcpp::warning("Seed stage set to NULL but R > 0. Check input data.");
        throw id;
    }
    /*Individual *i =*/ new Individual(arena,this,x,y);
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
    Position p;
    switch(kernelType){
        case 0: /* Fully random on the arena */
            return Position(Random(arena->getWidth()),Random(arena->getHeight()));
        case 1: /* EXPONENTIAL */
        default:
            if(dispersalRadius <= 0) return Position(0,0);
            p = RandomDirection();
            return Exponential(1.0/dispersalRadius)*p;
    }
}

double Species::getTotalRate(){
    totalRate = 0;
    std::list<Individual*>::iterator i;

    for(i=population.begin();i!=population.end();i++){
        totalRate += (*i)->getTotalRate();
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

    for(i=population.begin();i!=population.end();i++){
        r -= (*i)->getTotalRate();
        if(r < 0) {
            (*i)->act();
            return;
        }
    }
    /* if the below code is executed, it's becase no individual was selected */
    Rcpp::warning ("No individual selected on Species::act");
}

void Species::setNextStage(Species *st) {nextStage = st;}
void Species::setSeedStage(Species *st, double dispersal, int kernel) {
    seedStage = st;
    dispersalRadius = dispersal;
    kernelType=kernel;
}

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
double Species::getInteraction(int species_id, Position p){return interactions[species_id]+arena->getStressValue(p)*interactionVariation;}
int Species::getId(){return id;}
double Species::getD(Position p){
    if(maxStressEffect == 0){
        return D;
    }
    else {
        return arena->getStressValue(p)*maxStressEffect;
    }
}

int Species::getAbundance(){
    return population.size();
}

void Species::setInteractionVariation(double maxeffect){interactionVariation=maxeffect;}
