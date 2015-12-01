openRprof <- function(){Rprof(memory.profiling=TRUE)}

closeRprof <- function(){
Rprof(NULL)
summaryRprof("Rprof.out", memory="both")
}
