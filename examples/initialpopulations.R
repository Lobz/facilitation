
generate.overdisperse<-function(species.id=1,distance=4,show.radius=F,height=100,width=100){
    community(1,1,parameters=data.frame(0,0,20,distance),init=100,interactions=matrix(-100),dispersal=1,dispKernel="random",height=height,width=width)->m
    if(show.radius){
        m$radius=show.radius
        spatialplot(m,2)
    }
    d<-m$data
    h<-d[is.na(d$endtime),]
    n<-nrow(h)
    h$begintime<-rep(0,n)
    h$id<-1:n
    h$sp<-rep(species.id,n)
    h
}

initial.distribution<-function(init,height=100,width=100,min.id=1){
    sp<-unlist(lapply(1:length(init),function(i){rep(i,init[i])}))
    n<-length(sp)
    id<-1:n + min.id-1
    x<-runif(n,0,width)
    y<-runif(n,0,height)
    bt<-rep(0,n)
    et<-rep(NA,n)
    data.frame(sp=sp,id=id,x=x,y=y,begintime=bt,endtime=et)
}


