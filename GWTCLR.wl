(* ::Package:: *)
(* :Title: GWTCLR *)
(* :Author: Yang Liu, Tommy Lam *)
(* :Date: 2017-04-01 *)

(* :Package Version: 1.0 *)
(* :Mathematica Version: 11 *)


BeginPackage["GWTCLR`"]

Unprotect @@ Names["GWTCLR`*"];
ClearAll @@ Names["GWTCLR`*"];

TNear::usage="tao-nearest set capture function"

FinCom::usage="FinCom[a_,d_,u_,v_,band_,DATA_] is used to give the raw GWTCLR estimates of beta and the corresponding log-likelihood in each step of the iteration.a is the initial value of the iteration\:ff0cd is the temporal correlation parameter\:ff0cu,v are the geographical coordinates\:ff0cband is the bandwidth of geograhical weight function,DATA is the data which used."

BetaFinCom::usage="BetaFinCom[a_,d_,u_,v_,band_,DATA_] is used to give the raw GWTCLR estimates after 10 iterations,you can change the iteration time by changing {i,10} to {i,any value},all other defination are concur with the FinCom."

LikFinCom::usage="LikFinCom[d_,u_,v_,band_,DATA_] is used to obtain the log-likelihood value after 10 iterations.You can set your own iteration times by changing {i,10} to {i,any value},d is temporal correlation parameter,u and v is geographical coordinates, band is the geographical bandwidth of geographical weight function."

PlotLik::usage="PlotLik[a_,b_,n_,u_,v_,band_,DATA_] is used to obtain the profile of temporal correlation parameter vs Log-Likelihood value. This can help to choose the best temporal correlation parameter by choosing the one with maximum log-likelihood value. a is the lower boundry of searching region\:ff0cb is the upper boundry of searching region\:ff0cn is the searching stepsize, u and v is the geographical coordinates, band is the bandwidth of the geographical weight funtion, DATA is the data used for analysis"

ResAP::usage="ResAP[a_,b_,n_,u_,v_,band_,DATA_] can automatically give you the best temporal correlation parameter which gives the maximum log-likelihood. a is the lower boundry of searching region\:ff0cb is the upper boundry of searching region\:ff0cn is the searching stepsize, u and v is the geographical coordinates, band is the bandwidth of the geographical weight funtion, DATA is the data used for analysis."

RawEs::usage="RawEs[Tim_,tao_,d_,u_,v_,band_,DATA_] gives you a set of raw GWTCLR estimates for a set of times which you are interested. Tim is a vector with elements being the time point at which raw estimates of GWTCLR is calculated, tao is the range of the \[Tau]-nearest set\:ff0cd is the temporal correlation parameter\:ff0cu and v are geographical coordinates\:ff0cband is the bandwidth of geographical weight function\:ff0cDATA is the data for analysis."

RawCv::usage="RawCv[Tim_,tao_,d_,u_,v_,band_,betaS_,DATA_] gives the variance-covariance of the raw estimates set which obtained from RawEs. Tim is a vector with elements being the time point at which raw estimates of GWTCLR is calculated, tao is the range of the \[Tau]-nearest set\:ff0cd is the temporal correlation parameter\:ff0cu and v are geographical coordinates\:ff0cband is the bandwidth of geographical weight function\:ff0cbetaS is the raw estimates set obtained from RawEs, DATA is the data for analysis."

RefineEs::usage="RefineEs[t_,p_,h_,Tim_,betaS_] gives the refined estimates of GWTCLR. t is the time points at which refined estimates of GWTCLR calculated\:ff0cp is the order of the Polynomial non-parametric smoothing\:ff0ch is the bandwidth of the Polynomial kernel function\:ff0cTim is a vector with elements being the time point at which raw estimates of GWTCLR is calculated\:ff0cCv is the variance-covariance of the raw estimates set obtained from RawCv."

RefineVar::usage="RefineVar[t_,p_,h_,Tim_,Cv_] gives the variance-covariance of the refined estimates. t is the time points at which refined estimates of GWTCLR calculated\:ff0cp is the order of the Polynomial non-parametric smoothing\:ff0ch is the bandwidth of the Polynomial kernel function, Tim is a vector with elements being the time point at which raw estimates of GWTCLR is calculated\:ff0cCv is the variance-covariance of the raw estimates set obtained from RawCv."

PlotRefine::usage="PlotRefine[a_,b_,n_,p_,h_,Tim_,betaS_,Cv_] gives the graph of the refined estimates of GWTCLR along with their confidence interval. a is the lower boundary of the time period, b is the upper boundary of the time period, n means that we are drawing the nth coefficiency, p is the order of the Polynomial non-parametric smoothing, h is the bandwidth of the Polynomial kernel function\:ff0cTim is a vector with elements being the time point at which raw estimates of GWTCLR is calculated\:ff0cbetaS is the raw estimates set obtained from RawEs, Cv is the variance-covariance of the raw estimates set obtained from RawCv."


Begin["`Private`"]

(*Data should be defined in a fixed pattern as following example*)
(*number of event happens\:ff0ctotal number of event\:ff0clatitude u\:ff0clongitude v\:ff0csampling time\:ff0cintercept\:ff0cindependent variable 1\:ff0cindependent variable 2,...,independent variable p*)
D1={18,20,32,134,1,1,34,80,90};
D2={34,56,32,134,2,1,33,93,60};
D3={21,43,32,134,3,1,29,110,49};
D4={13,14,32,134,4,1,35,120,93};
D5={12,31,32,134,5,1,28,78,38};
D6={56,93,32,134,6,1,19,102,60};
D7={1,12,32,134,7,1,10,91,8};
D8={3,45,32,134,8,1,11,82,7};
D9={21,24,75,163,1,1,13,45,88};
D10={14,15,75,163,2,1,10,34,93};
D11={51,54,75,163,3,1,12,25,94};
D12={24,54,75,163,4,1,18,31,45};
D13={1,43,75,163,5,1,42,142,2.3};
D14={32,105,75,163,6,1,34,39,30};
D15={21,67,75,163,7,1,27,65,31};
D16={3,65,75,163,8,1,39,76,4.6};
D17={45,103,53,141,1,1,36,65,43};
D18={13,42,53,141,2,1,26,49,31};
D19={15,21,53,141,7,1,19,40,71};
DATA={D1,D2,D3,D4,D5,D6,D7,D8,D9,D10,D11,D12,D13,D14,D15,D16,D17,D18,D19};

(*The following codes are basic code used to construct the final function,not important for using GWTCLR*)
(*define probability function*)
prob[x_,beta_]:=Exp[x.beta]/(1+Exp[x.beta]);

(*define temporal correlation function,t1 and t2 is the time,and d is the temporal correlation parameter*)
(*rou[t1_,t2_,d_]:=Exp[-Abs[t1-t2]*Exp[d]];a alternative choice for temporal correlation function,you can define your own function and replace the following one,but please follow my pattern by defining the function as rou[t1_,t2_,d_]*)
rou[t1_,t2_,d_]:=d^(Abs[t1-t2]);

(*tao-nearest set capture function*)
(*t is the time which we need\:ff0ctao is the range of the tao-nearest set\:ff0cDATA is the data which used to devide into tao-nearest sets*)
TNear[t_,tao_,DATA_]:=Pick[DATA,Table[Abs[DATA[[i]][[5]]-t]<=tao,{i,1,Length[DATA]}]];

(*define geographical weighted function,this is Gaussian distance decay-based function,you can define your own function,but you need follow my pattern by defining the function as GeoW[x_,y_,band_]*)
GeoW[x_,y_,band_]:=N[Exp[-((QuantityMagnitude[GeoDistance[x,y[[3;;4]]]])^2)/(band^2)]];
(*GeoW[x_,y_,band_]:=N[If[EuclideanDistance[x,y[[3;;4]]]<band,(1-SquaredEuclideanDistance[x[[3;;4]],y[[3;;4]]]/(band^2))^2,0]];this is a alternative choice (Bi-square weighting function)*)

(*define non-parametric kernel function*)
Ker[x_]:=(1/Sqrt[2*Pi])*Exp[-(x^2)/2];

(*define one-dimensional probability function*)
op11[x_,beta_]:=CDF[BinormalDistribution[0],{Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]],Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]]}];
op10[x_,beta_]:=CDF[BinormalDistribution[0],{Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]],-Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]]}];
op00[x_,beta_]:=CDF[BinormalDistribution[0],{-Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]],-Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]]}];
(*define multi-dimensional probability function*)
p11[x_,y_,beta_,d_]:=CDF[BinormalDistribution[rou[x[[5]],y[[5]],d]],{Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]],Quantile[NormalDistribution[0,1],prob[y[[6;;Length[x]]],beta]]}];
p10[x_,y_,beta_,d_]:=CDF[NormalDistribution[0,1],Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]]]-p11[x,y,beta,d];
p01[x_,y_,beta_,d_]:=CDF[NormalDistribution[0,1],Quantile[NormalDistribution[0,1],prob[y[[6;;Length[x]]],beta]]]-p11[x,y,beta,d];
p00[x_,y_,beta_,d_]:=1-p11[x,y,beta,d]-p10[x,y,beta,d]-p01[x,y,beta,d];


(*define one-dimensional probability function's derivative*)
odp11[x_,beta_]:=CDF[NormalDistribution[0,1],Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]]]*(Exp[x[[6;;Length[x]]].beta]/(1+Exp[x[[6;;Length[x]]].beta])^2)*x[[6;;Length[x]]]+CDF[NormalDistribution[0,1],Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]]]*(Exp[x[[6;;Length[x]]].beta]/(1+Exp[x[[6;;Length[x]]].beta])^2)*x[[6;;Length[x]]];
odp10[x_,beta_]:=CDF[NormalDistribution[0,1],-Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]]]*(Exp[x[[6;;Length[x]]].beta]/(1+Exp[x[[6;;Length[x]]].beta])^2)*x[[6;;Length[x]]]-CDF[NormalDistribution[0,1],Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]]]*(Exp[x[[6;;Length[x]]].beta]/(1+Exp[x[[6;;Length[x]]].beta])^2)*x[[6;;Length[x]]];
odp00[x_,beta_]:=-CDF[NormalDistribution[0,1],-Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]]]*(Exp[x[[6;;Length[x]]].beta]/(1+Exp[x[[6;;Length[x]]].beta])^2)*x[[6;;Length[x]]]-CDF[NormalDistribution[0,1],-Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]]]*(Exp[x[[6;;Length[x]]].beta]/(1+Exp[x[[6;;Length[x]]].beta])^2)*x[[6;;Length[x]]];
(*define multi-dimensional probability function's derivative*)
dp11[x_,y_,beta_,d_]:=CDF[NormalDistribution[0,1],(Quantile[NormalDistribution[0,1],prob[y[[6;;Length[x]]],beta]]-Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]]*rou[x[[5]],y[[5]],d])/(Sqrt[1-(rou[x[[5]],y[[5]],d])^2])]*(Exp[x[[6;;Length[x]]].beta]/(1+Exp[x[[6;;Length[x]]].beta])^2)*x[[6;;Length[x]]]+CDF[NormalDistribution[0,1],(Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]]-Quantile[NormalDistribution[0,1],prob[y[[6;;Length[x]]],beta]]*rou[x[[5]],y[[5]],d])/(Sqrt[1-(rou[x[[5]],y[[5]],d])^2])]*(Exp[y[[6;;Length[x]]].beta]/(1+Exp[y[[6;;Length[x]]].beta])^2)*y[[6;;Length[x]]];
dp10[x_,y_,beta_,d_]:=CDF[NormalDistribution[0,1],(-Quantile[NormalDistribution[0,1],prob[y[[6;;Length[x]]],beta]]+Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]]*rou[x[[5]],y[[5]],d])/(Sqrt[1-(rou[x[[5]],y[[5]],d])^2])]*(Exp[x[[6;;Length[x]]].beta]/(1+Exp[x[[6;;Length[x]]].beta])^2)*x[[6;;Length[x]]]-CDF[NormalDistribution[0,1],(Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]]-Quantile[NormalDistribution[0,1],prob[y[[6;;Length[x]]],beta]]*rou[x[[5]],y[[5]],d])/(Sqrt[1-(rou[x[[5]],y[[5]],d])^2])]*(Exp[y[[6;;Length[x]]].beta]/(1+Exp[y[[6;;Length[x]]].beta])^2)*y[[6;;Length[x]]];
dp01[x_,y_,beta_,d_]:=-CDF[NormalDistribution[0,1],(Quantile[NormalDistribution[0,1],prob[y[[6;;Length[x]]],beta]]-Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]]*rou[x[[5]],y[[5]],d])/(Sqrt[1-(rou[x[[5]],y[[5]],d])^2])]*(Exp[x[[6;;Length[x]]].beta]/(1+Exp[x[[6;;Length[x]]].beta])^2)*x[[6;;Length[x]]]+CDF[NormalDistribution[0,1],(-Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]]+Quantile[NormalDistribution[0,1],prob[y[[6;;Length[x]]],beta]]*rou[x[[5]],y[[5]],d])/(Sqrt[1-(rou[x[[5]],y[[5]],d])^2])]*(Exp[y[[6;;Length[x]]].beta]/(1+Exp[y[[6;;Length[x]]].beta])^2)*y[[6;;Length[x]]];
dp00[x_,y_,beta_,d_]:=-CDF[NormalDistribution[0,1],(-Quantile[NormalDistribution[0,1],prob[y[[6;;Length[x]]],beta]]+Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]]*rou[x[[5]],y[[5]],d])/(Sqrt[1-(rou[x[[5]],y[[5]],d])^2])]*(Exp[x[[6;;Length[x]]].beta]/(1+Exp[x[[6;;Length[x]]].beta])^2)*x[[6;;Length[x]]]-CDF[NormalDistribution[0,1],(-Quantile[NormalDistribution[0,1],prob[x[[6;;Length[x]]],beta]]+Quantile[NormalDistribution[0,1],prob[y[[6;;Length[x]]],beta]]*rou[x[[5]],y[[5]],d])/(Sqrt[1-(rou[x[[5]],y[[5]],d])^2])]*(Exp[y[[6;;Length[x]]].beta]/(1+Exp[y[[6;;Length[x]]].beta])^2)*y[[6;;Length[x]]];


I1[x_,beta_]:=Binomial[x[[1]],2]*(1/op11[x,beta])*odp11[x,beta]+x[[1]]*(x[[2]]-x[[1]])*(1/op10[x,beta])*odp10[x,beta]+Binomial[x[[2]]-x[[1]],2]*(1/op00[x,beta])*odp00[x,beta];

O1[x_,y_,beta_,d_]:=x[[1]]*y[[1]]*(1/p11[x,y,beta,d])*dp11[x,y,beta,d]+x[[1]]*(y[[2]]-y[[1]])*(1/p10[x,y,beta,d])*dp10[x,y,beta,d]+y[[1]]*(x[[2]]-x[[1]])*(1/p01[x,y,beta,d])*dp01[x,y,beta,d]+(x[[2]]-x[[1]])*(y[[2]]-y[[1]])*(1/p00[x,y,beta,d])*dp00[x,y,beta,d];

Od2p[x_,y_,beta_,d_]:=-x[[2]]*y[[2]]*((Outer[Times,dp11[x,y,beta,d],dp11[x,y,beta,d]]*(1/p11[x,y,beta,d]))+(Outer[Times,dp10[x,y,beta,d],dp10[x,y,beta,d]]*(1/p10[x,y,beta,d]))+(Outer[Times,dp01[x,y,beta,d],dp01[x,y,beta,d]]*(1/p01[x,y,beta,d]))+(Outer[Times,dp00[x,y,beta,d],dp00[x,y,beta,d]]*(1/p00[x,y,beta,d])));

Id2p[x_,beta_]:=-Binomial[x[[2]],2]*(Outer[Times,odp11[x,beta],odp11[x,beta]]*(1/op11[x,beta])+2*Outer[Times,odp10[x,beta],odp10[x,beta]]*(1/op10[x,beta])+Outer[Times,odp00[x,beta],odp00[x,beta]]*(1/op00[x,beta]));



GTDE1[beta_,d_,DATA_]:=(DR=0;
Do[DR+=I1[DATA[[i]],beta],{i,1,Length[DATA]}];
Do[DR+=O1[DATA[[i]],DATA[[j]],beta,d],{i,1,Length[DATA]-1},{j,i+1,Length[DATA]}];DR);

DE1[a_,b_,band_,beta_,d_,DATA_]:=(D1R=0;
D1Set=Split[DATA,#1[[3;;4]]==#2[[3;;4]]&];
Do[D1R+=GeoW[{a,b},D1Set[[i]][[1]],band]*(1/(Total[D1Set[[i]][[All,2]]]-1))*GTDE1[beta,d,D1Set[[i]]],{i,1,Length[D1Set]}];D1R);


GTDE2[beta_,d_,DATA_]:=(FSI=0;
Do[FSI+=Id2p[DATA[[i]],beta],{i,1,Length[DATA]}];
Do[FSI+=Od2p[DATA[[i]],DATA[[j]],beta,d],{i,1,Length[DATA]-1},{j,i+1,Length[DATA]}];FSI);

DE2[a_,b_,band_,beta_,d_,DATA_]:=(D2R=0;
D1Set=Split[DATA,#1[[3;;4]]==#2[[3;;4]]&];
Do[D2R+=GeoW[{a,b},D1Set[[i]][[1]],band]*(1/(Total[D1Set[[i]][[All,2]]]-1))*GTDE2[beta,d,D1Set[[i]]],{i,1,Length[D1Set]}];D2R);

(*log-likelihood*)
InLik[x_,beta_]:=Binomial[x[[1]],2]*Log[op11[x,beta]]+x[[1]]*(x[[2]]-x[[1]])*Log[op10[x,beta]]+Binomial[x[[2]]-x[[1]],2]*Log[op00[x,beta]];
OutLik[x_,y_,beta_,d_]:=x[[1]]*y[[1]]*Log[p11[x,y,beta,d]]+x[[1]]*(y[[2]]-y[[1]])*Log[p10[x,y,beta,d]]+y[[1]]*(x[[2]]-x[[1]])*Log[p01[x,y,beta,d]]+(x[[2]]-x[[1]])*(y[[2]]-y[[1]])*Log[p00[x,y,beta,d]];
GTLik[beta_,d_,DATA_]:=(1/(Total[DATA[[All,2]]]-1))*(L=0;
Do[L+=InLik[DATA[[i]],beta],{i,1,Length[DATA]}];
Do[L+=OutLik[DATA[[i]],DATA[[j]],beta,d],{i,1,Length[DATA]-1},{j,i+1,Length[DATA]}];L);
Lik[a_,b_,band_,beta_,d_,DATA_]:=(Lik1=0;
D1Set=Split[DATA,#1[[3;;4]]==#2[[3;;4]]&];
Do[Lik1+=GeoW[{a,b},D1Set[[i]][[1]],band]*GTLik[beta,d,D1Set[[i]]],{i,1,Length[D1Set]}];Lik1);
(*End of basic codes*)









(*The following codes give several function for GWTCLR*)
(*FinCom is used to give the raw GWTCLR estimates of beta and the corresponding log-likelihood in each step of the iteration.a is the initial value of the iteration\:ff0cd is the temporal correlation parameter\:ff0cu,v are the geographical coordinates\:ff0cband is the bandwidth of geograhical weight function,DATA is the data which used*)
(*We set a default 10 iteration.You can set your own iteration times by changing Print[N[Lik[u,v,band,beta,d,DATA]]],{i,10}] to Print[N[Lik[u,v,band,beta,d,DATA]]],{i,any value}]*)
FinCom[a_,d_,u_,v_,band_,DATA_]:=(beta=a;
Do[beta=N[beta-Inverse[N[DE2[u,v,band,beta,d,DATA]]].N[DE1[u,v,band,beta,d,DATA]]];Print[beta];
Print[N[Lik[u,v,band,beta,d,DATA]]],{i,10}])

(*BetaFinCom is used to give the raw GWTCLR estimates after 10 iterations,you can change the iteration time by changing {i,10} to {i,any value},all other defination are concur with the FinCom*)
BetaFinCom[a_,d_,u_,v_,band_,DATA_]:=(beta=a;
Do[beta=N[beta-Inverse[N[DE2[u,v,band,beta,d,DATA]]].N[DE1[u,v,band,beta,d,DATA]]],{i,10}];beta)

(*LikFinCom is used to obtain the log-likelihood value after 10 iterations.You can set your own iteration times by changing {i,10} to {i,any value}*)
(*d is temporal correlation parameter,u and v is geographical coordinates,band is the geographical bandwidth of geographical weight function*)
LikFinCom[d_,u_,v_,band_,DATA_]:=(beta=Table[0,{n,Length[DATA[[1]]]-5}];
Do[beta=N[beta-Inverse[N[DE2[u,v,band,beta,d,DATA]]].N[DE1[u,v,band,beta,d,DATA]]],{i,10}];
N[Lik[u,v,band,beta,d,DATA]])

(*PlotLik is used to obtain the profile of temporal correlation parameter vs Log-Likelihood value.This can help to choose the best temporal correlation parameter by choosing the one with maximum log-likelihood value*)
(*a is the lower boundry of searching region\:ff0cb is the upper boundry of searching region\:ff0cn is the searching stepsize,u and v is the geographical coordinates,band is the bandwidth of the geographical weight funtion,DATA is the data used for analysis*)
PlotLik[a_,b_,n_,u_,v_,band_,DATA_]:=(A=Table[0,{i,a,b,n}];
Do[A[[Round[((i-a)/n)+1]]]=LikFinCom[i,u,v,band,DATA],{i,a,b,n}];
ListLinePlot[Transpose[Join[{Table[i,{i,a,b,n}]},{A}]],AxesLabel->{Temporal Correlation Parameter,Log-Likelihood},ImageSize->Large])

(*ResAP can automatically give you the best temporal correlation parameter which gives the maximum log-likelihood*)
(*a is the lower boundry of searching region\:ff0cb is the upper boundry of searching region\:ff0cn is the searching stepsize,u and v is the geographical coordinates,band is the bandwidth of the geographical weight funtion,DATA is the data used for analysis*)
ResAP[a_,b_,n_,u_,v_,band_,DATA_]:=(ArP=Table[0,{i,a,b,n}];
Pamd=Table[0,{i,a,b,n}];
Do[ArP[[Round[((i-a)/n)+1]]]=LikFinCom[i,u,v,band,DATA],{i,a,b,n}];
Do[If[ArP[[j]]==Max[ArP],Pamd[[j]]=(j-1)*n+a,Pamd[[j]]=0],{j,1,Length[ArP]}];Total[Pamd]);



(*DEV is a inner function of RawVar,RawVar gives the variance-covariance of the raw estimates of GWTCLR*)
(*u,v are geographical coordinates\:ff0cband is the bandwidth of geographical weight function\:ff0cd is the temporal correlation parameter\:ff0cDATA is the data for analysis*)
DEV[u_,v_,band_,beta_,d_,DATA_]:=(D1V=0;
D1Set=Split[DATA,#1[[3;;4]]==#2[[3;;4]]&];
Do[D1V+=(GeoW[{u,v},D1Set[[i]][[1]],band]^2)*Outer[Times,(1/(Total[D1Set[[i]][[All,2]]]-1))*GTDE1[beta,d,D1Set[[i]]],(1/(Total[D1Set[[i]][[All,2]]]-1))*GTDE1[beta,d,D1Set[[i]]]],{i,1,Length[D1Set]}];D1V);

RawVar[u_,v_,band_,d_,DATA_]:=Inverse[N[DE2[u,v,band,BetaFinCom[Table[0,{n,Length[DATA[[1]]]-5}],d,u,v,band,DATA],d,DATA]]].DEV[u,v,band,BetaFinCom[Table[0,{n,Length[DATA[[1]]]-5}],d,u,v,band,DATA],d,DATA].Inverse[N[DE2[u,v,band,BetaFinCom[Table[0,{n,Length[DATA[[1]]]-5}],d,u,v,band,DATA],d,DATA]]];


(*RawTe gives the result of Null hypothesis test.It shows whether the estimate is significantly different with 0*)
(*u,v are geographical coordinates\:ff0cband is the bandwidth of geographical weight function\:ff0cd is the temporal correlation parameter\:ff0cDATA is the data for analysis*)
RawTe[u_,v_,band_,d_,DATA_]:=(B=Table[0,{n,Length[DATA[[1]]]-5}];
beta=BetaFinCom[Table[0,{n,Length[DATA[[1]]]-5}],d,u,v,band,DATA];
betaVar=RawVar[u,v,band,d,DATA];
Do[B[[i]]=N[beta[[i]]]-1.96*N[Sqrt[betaVar[[i]][[i]]]]<0<N[beta[[i]]]+1.96*N[Sqrt[betaVar[[i]][[i]]]],{i,1,Length[DATA[[1]]]-5}];B);

(*PaDEV is a inner function of PaRawCv,PaRawCv gives the variance-covariance of a pair of two raw eatimate of GWTCLR*)
(*u and v are the geographical coordinates\:ff0cband is the bandwidth of geographical weight function\:ff0cd is the temporal correlation parameter\:ff0cbetaa is the raw estimates of data a\:ff0cbetab is the raw estimates of data b\:ff0cDATAa is data a for analysis,DATAb is data b for analysis*)
PaDEV[u_,v_,band_,betaa_,betab_,d_,DATAa_,DATAb_]:=(PaD1V=0;
D1Set=Split[DATAa,#1[[3;;4]]==#2[[3;;4]]&];
D2Set=Split[DATAb,#1[[3;;4]]==#2[[3;;4]]&];
Do[If[D1Set[[i]][[1]][[3;;4]]==D2Set[[j]][[1]][[3;;4]],PaD1V+=(GeoW[{u,v},D1Set[[i]][[1]],band]^2)*Outer[Times,(1/(Total[D1Set[[i]][[All,2]]]-1))*GTDE1[betaa,d,D1Set[[i]]],(1/(Total[D2Set[[j]][[All,2]]]-1))*GTDE1[betab,d,D2Set[[j]]]],PaD1V+=0],{i,1,Length[D1Set]},{j,1,Length[D2Set]}];PaD1V);
PaRawCv[u_,v_,band_,betaa_,betab_,d_,DATAa_,DATAb_]:=Inverse[N[DE2[u,v,band,betaa,d,DATAa]]].PaDEV[u,v,band,betaa,betab,d,DATAa,DATAb].Inverse[N[DE2[u,v,band,betab,d,DATAb]]];

(*The following is for the final refined ALR*)
(*RawEs gives you a set of raw GWTCLR estimates for a set of times which you are interested*)
(*Tim is a vector with elements being the time point at which raw estimates of GWTCLR is calculated\:ff0ctao is the range of the \[Tau]-nearest set\:ff0cd is the temporal correlation parameter\:ff0cu and v are geographical coordinates\:ff0cband is the bandwidth of geographical weight function\:ff0cDATA is the data for analysis*)
RawEs[Tim_,tao_,d_,u_,v_,band_,DATA_]:=(betaa=Table[0,{j,Length[DATA[[1]]]-5}];
betaH=Table[betaa,{j,Length[Tim]}];
ste=1;
Do[betaH[[ste]]=BetaFinCom[betaa,d,u,v,band,TNear[t,tao,DATA]];
ste+=1,{t,Tim}];betaH);
(*RawCv gives the variance-covariance of the raw estimates set which obtained from RawEs*)
(*Tim is a vector with elements being the time point at which raw estimates of GWTCLR is calculated\:ff0ctao is the range of the \[Tau]-nearest set\:ff0cd is the temporal correlation parameter\:ff0cu and v are geographical coordinates\:ff0cband is the bandwidth of geographical weight function\:ff0cbetaS is the raw estimates set obtained from RawEs,DATA is the data for analysis*)
RawCv[Tim_,tao_,d_,u_,v_,band_,betaS_,DATA_]:=Table[PaRawCv[u,v,band,betaS[[i]],betaS[[j]],d,TNear[Tim[[i]],tao,DATA],TNear[Tim[[j]],tao,DATA]],{i,Length[Tim]},{j,Length[Tim]}];


(*Polynomial non-parametric smoothing*)

(*RefineEs gives the refined estimates of GWTCLR*)
(*t is the time points at which refined estimates of GWTCLR calculated\:ff0cp is the order of the Polynomial non-parametric smoothing\:ff0ch is the bandwidth of the Polynomial kernel function\:ff0cTim is a vector with elements being the time point at which raw estimates of GWTCLR is calculated\:ff0cbetaS is the raw estimates set obtained from RawEs*)
RefineEs[t_,p_,h_,Tim_,betaS_]:=(DesM=Table[Table[0,{j,0,p}],{i,Length[Tim]}];
Do[DesM[[n]]=Table[Tim[[n]]^m,{m,0,p}],{n,Length[Tim]}];
Omig=DiagonalMatrix[Table[Ker[(t-l)/h],{l,Tim}]];
Table[t^j,{j,0,p}].Inverse[Transpose[DesM].Omig.DesM].Transpose[DesM].Omig.betaS);

(*RefineVar gives the variance-covariance of the refined estimates*)
(*t is the time points at which refined estimates of GWTCLR calculated\:ff0cp is the order of the Polynomial non-parametric smoothing\:ff0ch is the bandwidth of the Polynomial kernel function\:ff0cTim is a vector with elements being the time point at which raw estimates of GWTCLR is calculated\:ff0cCv is the variance-covariance of the raw estimates set obtained from RawCv*)
RefineVar[t_,p_,h_,Tim_,Cv_]:=(A=0;
DesM=Table[Table[0,{j,0,p}],{i,Length[Tim]}];
Do[DesM[[n]]=Table[Tim[[n]]^m,{m,0,p}],{n,Length[Tim]}];
Omig=DiagonalMatrix[Table[Ker[(t-l)/h],{l,Tim}]];
Do[A+=(Table[t^j,{j,0,p}].Inverse[Transpose[DesM].Omig.DesM].Transpose[DesM].Omig[[i]])*(Table[t^j,{j,0,p}].Inverse[Transpose[DesM].Omig.DesM].Transpose[DesM].Omig[[j]])*Cv[[i,j]],{i,1,Length[Tim]},{j,1,Length[Tim]}];A)

(*PlotRefine gives the graph of the refined estimates of GWTCLR along with their confidence interval*)
(*a is the lower boundary of the time period,b is the upper boundary of the time period,n means that we are drawing the nth coefficiency,p is the order of the Polynomial non-parametric smoothing\:ff0ch is the bandwidth of the Polynomial kernel function\:ff0cTim is a vector with elements being the time point at which raw estimates of GWTCLR is calculated\:ff0cbetaS is the raw estimates set obtained from RawEs,Cv is the variance-covariance of the raw estimates set obtained from RawCv*)
PlotRefine[a_,b_,n_,p_,h_,Tim_,betaS_,Cv_]:=Plot[{RefineEs[x,p,h,Tim,betaS][[n]]-1.96*Sqrt[RefineVar[x,p,h,Tim,Cv][[n,n]]],RefineEs[x,p,h,Tim,betaS][[n]],RefineEs[x,p,h,Tim,betaS][[n]]+1.96*Sqrt[RefineVar[x,p,h,Tim,Cv][[n,n]]]},{x,a,b},Filling->{1->{3}},AxesLabel->{Time,Beta},ImageSize->Large];

End[]
EndPackage[]
