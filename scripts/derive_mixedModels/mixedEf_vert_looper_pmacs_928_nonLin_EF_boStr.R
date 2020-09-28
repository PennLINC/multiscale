library(mgcv)
library(boot)
library(reshape2)
library(lme4)

# this file has bblid, EF, Age, Motion, Sex. Was originally purposed for matlab (hence ML)
demoEF<-read.csv('~/forPMACS_EF.csv',header=F)
colnames(demoEF)<-c('scanid','bblid','EF','Age','Motion','Sex')
subjects<-read.csv('~/participants.txt',header = F)

# set colnames for proc. df
colnames(subjects)<-c("scanid")
df<-merge(subjects,demoEF,by="scanid")

# initialize output table
outputcolnames=c('s_Age','s_Scale','s_EF','AgeXScale','EFxScale','Motion','Sex')
outputrownames=c('Coef','BoStrCI_Low','BoStr_CI_Upp')
outarray=matrix(1,nrow=3,ncol=7)
colnames(outarray)=outputcolnames
rownames(outarray)=outputrownames

# 9/21/20 - bootstrap section added
returnLmCoefs<-function(d,i){
  # this sets I to the bootstrapped sample
  d2<-d[i,]
  model=gamm(value~Motion+Sex+ti(Scale,k=4)+ti(Age,k=4)+ti(EF,k=4)+ti(Scale,Age,k=4)+ti(Scale,EF,k=4),random=list(bblid=~1),data=d2)
  return(fixef(model$lme))
}

returnGammFs<-function(d,i){
  # same framework as above
  d2<-d[i,]
  model=gamm(value~Motion+Sex+ti(Scale,k=4)+ti(Age,k=4)+ti(EF,k=4)+ti(Scale,Age,k=4)+ti(Scale,EF,k=4),random=list(bblid=~1),data=d2)
  return(summary(model$gam)$s.table[,3])
}
#for (v in 1:17734){
# multi run version: split into 18 for simplicity

#for (v in 1:1000){
#for (v in 1001:2000){
#for (v in 2001:3000){
#for (v in 3001:4000){
#for (v in 4001:5000){
#for (v in 5001:6000){
#for (v in 6001:7000){
#for (v in 7001:8000){
#for (v in 8001:9000){
#for (v in 9001:10000){
#for (v in 10001:11000){
#for (v in 11001:12000){
#for (v in 12001:13000){
#for (v in 13001:14000){
#for (v in 14001:15000){
#for (v in 15001:16000){
#for (v in 16001:17000){
for (v in 17001:17734){

  print(v)
  
  # wrangle data, get variables into approp. var type
  vFP=paste('~/mixedEffectModels/v',v,'_bwVals_overScales.csv',sep='')
  verts=read.csv(vFP)
  colnames(verts)[30]<-'bblid'
  df_verts<-merge(df,verts,by="bblid")
  mdf_verts<-melt(df_verts,id=c(1,2,3,4,5,6))
  mdf_verts$bblid<-as.factor(mdf_verts$bblid)
  colnames(mdf_verts)[7]<-c('Scale')
  mdf_verts$Scale<-as.integer(mdf_verts$Scale)
  mdf_verts$Sex<-as.factor(mdf_verts$Sex)
  mdf_verts$Age<-as.numeric(mdf_verts$Age)
  mdf_verts$EF<-as.numeric(mdf_verts$EF)

  # model for this vertex
  model=gamm(value~Motion+Sex+ti(Scale,k=4)+ti(Age,k=4)+ti(EF,k=4)+ti(Scale,Age,k=4)+ti(Scale,EF,k=4),random=list(bblid=~1),data=mdf_verts)
  fe=fixef(model$lme)

  # pull out coefficients
  fMot=fe['XMotion']
  fSex=fe['XSex2']

  # for non-linear terms
  Fstats=summary(model$gam)$s.table[,3]
  fFAge=Fstats['ti(Age)']
  fFScale=Fstats['ti(Scale)']
  fFEF=Fstats['ti(EF)']
  fF_as_int=Fstats['ti(Scale,Age)']
  fF_es_int=Fstats['ti(Scale,EF)']

  # coefficients into first row, along with age x Intercept corr.
  outarray[1,1]=fFAge
  outarray[1,2]=fFScale
  outarray[1,3]=fFEF
  outarray[1,4]=fF_as_int
  outarray[1,5]=fF_es_int
  outarray[1,6]=fMot
  outarray[1,7]=fSex

  # linear coefs, hang on to yer bootstraps
  Lresults <- boot(data=mdf_verts, statistic=returnLmCoefs, R=1000)
  # index 1 is intercept
  # index 2 is Motion
  outarray[2,6]=boot.ci(Lresults,type="norm",index=2)$normal[2]
  outarray[3,6]=boot.ci(Lresults,type="norm",index=2)$normal[3]
  # index 3 is Sex
  outarray[2,7]=boot.ci(Lresults,type="norm",index=3)$normal[2]
  outarray[3,7]=boot.ci(Lresults,type="norm",index=3)$normal[3]
  
  # non linear coefs
  NLresults<-boot(data=mdf_verts,statistic=returnGammFs,R=1000)
  # index 1 is Scale
  outarray[2,2]=boot.ci(NLresults,type="norm",index=1)$normal[2]
  outarray[3,2]=boot.ci(NLresults,type="norm",index=1)$normal[3]
  # index 2 is Age
  outarray[2,1]=boot.ci(NLresults,type="norm",index=2)$normal[2]
  outarray[3,1]=boot.ci(NLresults,type="norm",index=2)$normal[3]
  # index 3 is EF
  outarray[2,3]=boot.ci(NLresults,type="norm",index=3)$normal[2]
  outarray[3,3]=boot.ci(NLresults,type="norm",index=3)$normal[3]
  # index 4 is age*Scale
  outarray[2,4]=boot.ci(NLresults,type="norm",index=4)$normal[2]
  outarray[3,4]=boot.ci(NLresults,type="norm",index=4)$normal[3]
  # index 5 is EF*scale
  outarray[2,5]=boot.ci(NLresults,type="norm",index=5)$normal[2]
  outarray[3,5]=boot.ci(NLresults,type="norm",index=5)$normal[3]

  write.table(outarray,file=paste('~/mixedEffectModels/Modeled_fSex_fMot_s4_fAgexScale_fEFxScale_raInt_v',v,'_bwVals_BoStr_overScales.csv',sep=''),sep=',',row.names=F,quote=F)
}
