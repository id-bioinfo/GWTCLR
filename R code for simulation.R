#This is the code for producing simulation data described in GWTCLR paper

simu1<-function(x,y,t){
  return(sign(x)*0.001*x^2 + sign(y)*0.001*y^2 + 0.05*sin(2*pi*((t-1)/20)+pi/2))
}

simu2<-function(t){
  return(3.5*(0.01*log(pi*((t-1)/20)+pi/2)-0.01))
}

u1<-rnorm(99,10,0.8)
v1<-rnorm(99,10,0.8)
u2<-rnorm(99,-10,0.8)
v2<-rnorm(99,-10,0.8)

for(i in 1:10){
  for(j in 1:10){
    u1[(i-1)*10+j]<-seq(8.2,12.2,0.4)[i]
    v1[(i-1)*10+j]<-seq(8.2,12.2,0.4)[j]
  }
}

for(i in 1:10){
  for(j in 1:10){
    u2[(i-1)*10+j]<-seq(-11.8,-8,0.4)[i]
    v2[(i-1)*10+j]<-seq(-11.8,-8,0.4)[j]
  }
}

u<-c(u1,u2)
v<-c(v1,v2)

dat<-data.frame(Lat=u,Lon=v)

store<-rep(0,200*21*8)
dim(store)<-c(200*21,8)

for(i in 1:200){
  for(t in 1:21){
    beta1<-simu1(dat$Lat[i],dat$Lon[i],t)
    beta2<-simu2(t)
    tmp<-runif(1,-5,5)
    ah<-runif(1,-50,50)
    a<-1+beta1*tmp+beta2*ah
    p<-exp(a)/(1+exp(a))
    store[21*(i-1)+t,1]<-rbinom(1,500,p)
    store[21*(i-1)+t,2]<-500
    store[21*(i-1)+t,3]<-dat$Lat[i]
    store[21*(i-1)+t,4]<-dat$Lon[i]
    store[21*(i-1)+t,5]<-t
    store[21*(i-1)+t,6]<-1
    store[21*(i-1)+t,7]<-tmp
    store[21*(i-1)+t,8]<-ah
  }
}

set<-data.frame(positive.number=store[,1],total.number=store[,2],Lat=store[,3],Lon=store[,4],time=store[,5],intercept=store[,6],X1=store[,7],X2=store[,8])

write.csv(set,file="Simulation data.csv")



