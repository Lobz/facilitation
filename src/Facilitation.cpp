#include"Species.hpp"

class Beneficiada : public Species {
	public:
	Beneficiada() : Species(3) {
		/* semente */
		LG[0] = .05; LR[0] = 0; LS[0] =.40; LRad[0] = 0;
		/* plântula */
		LG[1] = .05; LR[1] = 0; LS[1] =.40; LRad[1] = 0;
		/* adulta */
		LR[2] = 1; LS[2] =.40; LRad[2] = 0;
	}
};

class Facilitadora : public Species {
	public:
	Facilitadora() : Species(1) {
		LG[0] = 0; LR[0] = 0; LS[0] =0; LRad[0] = 0;
	}
};
