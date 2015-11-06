openRprof <- function(){Rprof(memory.profiling=TRUE)}

cloaseRprof <- function(){
Rprof(NULL)
summaryRprof("Rprof.out", memory="both")
}
