// This file was generated by Rcpp::compileAttributes
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

// simulation
Rcpp::DataFrame simulation(double maxtime, int num_stages, Rcpp::NumericVector parameters, double dispersal, Rcpp::NumericVector interactions, Rcpp::IntegerVector init, Rcpp::DataFrame history, bool restore, double w, double h, int bcond, int dkernel, int maxpop);
RcppExport SEXP facilitation_simulation(SEXP maxtimeSEXP, SEXP num_stagesSEXP, SEXP parametersSEXP, SEXP dispersalSEXP, SEXP interactionsSEXP, SEXP initSEXP, SEXP historySEXP, SEXP restoreSEXP, SEXP wSEXP, SEXP hSEXP, SEXP bcondSEXP, SEXP dkernelSEXP, SEXP maxpopSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< double >::type maxtime(maxtimeSEXP);
    Rcpp::traits::input_parameter< int >::type num_stages(num_stagesSEXP);
    Rcpp::traits::input_parameter< Rcpp::NumericVector >::type parameters(parametersSEXP);
    Rcpp::traits::input_parameter< double >::type dispersal(dispersalSEXP);
    Rcpp::traits::input_parameter< Rcpp::NumericVector >::type interactions(interactionsSEXP);
    Rcpp::traits::input_parameter< Rcpp::IntegerVector >::type init(initSEXP);
    Rcpp::traits::input_parameter< Rcpp::DataFrame >::type history(historySEXP);
    Rcpp::traits::input_parameter< bool >::type restore(restoreSEXP);
    Rcpp::traits::input_parameter< double >::type w(wSEXP);
    Rcpp::traits::input_parameter< double >::type h(hSEXP);
    Rcpp::traits::input_parameter< int >::type bcond(bcondSEXP);
    Rcpp::traits::input_parameter< int >::type dkernel(dkernelSEXP);
    Rcpp::traits::input_parameter< int >::type maxpop(maxpopSEXP);
    __result = Rcpp::wrap(simulation(maxtime, num_stages, parameters, dispersal, interactions, init, history, restore, w, h, bcond, dkernel, maxpop));
    return __result;
END_RCPP
}
