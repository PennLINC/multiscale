
v=commandArgs(trailingOnly=TRUE)
# load libraries
library(mgcv)
library(boot)
library(reshape2)
library(lme4)
demo<-read.csv('~/pnc_demo.csv')
subjects<-read.csv('~/participants.txt',header = F)
ageSex<-data.frame(demo$ageAtScan1,as.factor(demo$sex),demo$scanid,demo$bblid)
colnames(ageSex)[4]<-'bblid'
colnames(ageSex)[1]<-'Age'
Rest_Motion_Data <- read.csv("~/n1601_RestQAData_20170714.csv")
NBack_Motion_Data <- read.csv("~/n1601_NBACKQAData_20181001.csv")
Idemo_Motion_Data <- read.csv("~/n1601_idemo_FinalQA_092817.csv")
motmerge<-merge(Rest_Motion_Data,NBack_Motion_Data,by='bblid')
motmerge<-merge(motmerge,Idemo_Motion_Data,by='bblid')
motmerge$Motion <- (motmerge$restRelMeanRMSMotion + motmerge$nbackRelMeanRMSMotion + motmerge$idemoRelMeanRMSMotion)/3;
motiondf<-data.frame(motmerge$bblid,motmerge$Motion)
colnames(motiondf)<-c('bblid','Motion')
colnames(subjects)<-c("scanid")
colnames(ageSex)<-c("Age","Sex","scanid","bblid")
df<-merge(subjects,ageSex,by="scanid")
df<-merge(df,motiondf,by='bblid')

outputcolnames=c('s_Age','s_Scale','AgeXScale','Motion','Sex','ageInt')
outputrownames=c('Coef','BoStrCI_Low','BoStr_CI_Upp')
outarray=matrix(1,nrow=3,ncol=6)
colnames(outarray)=outputcolnames
rownames(outarray)=outputrownames
# 9/10/20 section to write out subject level intercepts and slopes
subjoutputcolnames=c('bblid','Intercept')
subjoutarray=matrix(1,nrow=693,ncol=2)
colnames(subjoutarray)=subjoutputcolnames


# 9/21/20 - bootstrap section added
returnLmCoefs<-function(d,i){
  # this sets I to the bootstrapped sample
  d2<-d[i,]
  model=gamm(value~Motion+Sex+ti(Scale,k=4,fx=T)+ti(Age,k=4,fx=T)+ti(Scale,Age,k=4,fx=T),random=list(bblid=~1),data=d2)
  return(fixef(model$lme))
}

returnGammFs<-function(d,i){
  # same framework as above
  d2<-d[i,]
  model=gamm(value~Motion+Sex+ti(Scale,k=4,fx=T)+ti(Age,k=4,fx=T)+ti(Scale,Age,k=4,fx=T),random=list(bblid=~1),data=d2)
  return(summary(model$gam)$s.table[,3])
}
#for (v in 1:17734){
# multi run version: split into 18 for simplicity

#for (v in 1:500){
#for (v in 501:1000){
#for (v in 1001:1500){
#for (v in 1501:2000){
#for (v in 2001:2500){
#for (v in 2501:3000){
#for (v in 3001:3500){
#for (v in 3501:4000){
#for (v in 4001:4500){
#for (v in 4501:5000){
#for (v in 5001:5500){
#for (v in 5501:6000){
#for (v in 6001:6500){
#for (v in 6501:7000){
#for (v in 7001:7500){
#for (v in 7501:8000){
#for (v in 8001:8500){
#for (v in 8501:9000){
#for (v in 9001:9500){
#for (v in 9501:10000){
#for (v in 10001:10500){
#for (v in 10501:11000){
#for (v in 11001:11500){
#for (v in 11501:12000){
#for (v in 12001:12500){
#for (v in 12501:13000){
#for (v in 13001:13500){
#for (v in 13501:14000){
#for (v in 14001:14500){
#for (v in 14501:15000){
#for (v in 15001:15500){
#for (v in 15501:16000){
#for (v in 16001:16500){
#for (v in 16501:17000){
#for (v in 17001:17500){
#for (v in 17501:17734){

  print(v)
  
  # wrangle data, get variables into approp. var type
  vFP=paste('~/mixedEffectModels/v',v,'_bwVals_overScales.csv',sep='')
  verts=read.csv(vFP)
  colnames(verts)[30]<-'bblid'
  df_verts<-merge(df,verts,by="bblid")
  mdf_verts<-melt(df_verts,id=c(1,2,3,4,5))
  mdf_verts$bblid<-as.factor(mdf_verts$bblid)
  colnames(mdf_verts)[6]<-c('Scale')
  mdf_verts$Scale<-as.integer(mdf_verts$Scale)
  mdf_verts$Sex<-as.factor(mdf_verts$Sex)
  mdf_verts$Age<-as.numeric(mdf_verts$Age)
  
  # model for this vertex
  model=gamm(value~Motion+Sex+ti(Scale,k=4,fx=T)+ti(Age,k=4,fx=T)+ti(Scale,Age,k=4,fx=T),random=list(bblid=~1),data=mdf_verts)
  fe=fixef(model$lme)
  #re=ranef(model$lme)
  #re=re$bblidi

  # pull out coefficients
  fMot=fe['XMotion']
  fSex=fe['XSex2']
  #fAge=fe['Age']
  #flSc=fe['Scale']
  #fIntrxn=fe['Scale:Age']
  Intercept=fe['(Intercept)']


  # for non-linear terms
  Fstats=summary(model$gam)$s.table[,3]
  fFAge=Fstats['ti(Age)']
  fFScale=Fstats['ti(Scale)']
  fFint=Fstats['ti(Scale,Age)']
  # intercept correlated with Age?
  #ageInt=cor.test(re$`(Intercept)`,df$Age,method='spearman')$estimate
  
  # coefficients into first row, along with age x Intercept corr.
  outarray[1,1]=fFAge
  outarray[1,2]=fFScale
  outarray[1,3]=fFint
  outarray[1,4]=fMot
  outarray[1,5]=fSex
  #outarray[1,6]=ageInt

  # linear coefs, hang on to yer bootstraps
  Lresults <- boot(data=mdf_verts, statistic=returnLmCoefs, R=1000)
  # index 1 is intercept
  # index 2 is Motion
  outarray[2,4]=boot.ci(Lresults,type="norm",index=2)$normal[2]
  outarray[3,4]=boot.ci(Lresults,type="norm",index=2)$normal[3]
  # index 3 is Sex
  outarray[2,5]=boot.ci(Lresults,type="norm",index=3)$normal[2]
  outarray[3,5]=boot.ci(Lresults,type="norm",index=3)$normal[3]
  
  # non linear coefs
  NLresults<-boot(data=mdf_verts,statistic=returnGammFs,R=1000)
  # index 1 is Scale
  outarray[2,2]=boot.ci(NLresults,type="norm",index=1)$normal[2]
  outarray[3,2]=boot.ci(NLresults,type="norm",index=1)$normal[3]
  # index 2 is Age
  outarray[2,1]=boot.ci(NLresults,type="norm",index=2)$normal[2]
  outarray[3,1]=boot.ci(NLresults,type="norm",index=2)$normal[3]
  # index 3 is age*logScale
  outarray[2,3]=boot.ci(NLresults,type="norm",index=3)$normal[2]
  outarray[3,3]=boot.ci(NLresults,type="norm",index=3)$normal[3]


  # no bootstrap equiv for int age correlation at the moment

  write.table(outarray,file=paste('~/mixedEffectModels/Modeled_fSex_fMot_s4fxT_fAgexScale_raInt_v',v,'_bwVals_BoStr_overScales.csv',sep=''),sep=',',row.names=F,quote=F)
  # 9/10/20 section to write out subject level intercepts and slopes
  #subjoutarray[,1]=df_verts$bblid
  #subjoutarray[,2]=re$`(Intercept)`
  #subjoutarray[,3]=re$`log(Scale)`
  #write.table(subjoutarray,file=paste('~/mixedEffectModels/Scales10thru20_subj_level_Modeled_fSca_fAge_fScaxAge_raScaS_raScaI_fM',v,'_bwVals_overScales.csv',sep=''),sep=',',row.names=F,quote=F)  
#}
