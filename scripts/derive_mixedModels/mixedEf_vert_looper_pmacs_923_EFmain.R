library(boot)
library(reshape2)
library(lme4)
library(mgcv)
# read in scale-constant data
demoEF<-read.csv('~/forPMACS_EF.csv',header=F)
colnames(demoEF)<-c('scanid','bblid','EF','Age','Motion','Sex')
subjects<-read.csv('~/participants.txt',header = F)
colnames(subjects)<-c("scanid")
df<-merge(subjects,demoEF,by="scanid")

outputcolnames=c('Motion','Sex','EF','logScale','Age','logScale_x_Age')
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
  model=glmer(value~Motion+Sex+EF+log(Scale)*Age+(1|bblid),data=d2)
  return(fixef(model))
}

for (v in 1:17734){
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
#for (v in 17001:17734){

  print(v)
  
  # wrangle data, get variables into approp. var type
  vFP=paste('~/mixedEffectModels/v',v,'_bwVals_overScales.csv',sep='')
  verts=read.csv(vFP)
  colnames(verts)[30]<-'bblid'
  df_verts<-merge(df,verts,by="bblid")
  # 6th id variable for EF
  mdf_verts<-melt(df_verts,id=c(1,2,3,4,5,6))
  mdf_verts$bblid<-as.factor(mdf_verts$bblid)
  colnames(mdf_verts)[7]<-c('Scale')
  mdf_verts$Scale<-as.integer(mdf_verts$Scale)
  # change scale from 1:29 to 2:30
  mdf_verts$Scale<-mdf_verts$Scale+1
  mdf_verts$Sex<-as.factor(mdf_verts$Sex)
  mdf_verts$Age<-as.numeric(mdf_verts$Age)
  mdf_verts$EF<-as.numeric(mdf_verts$EF)
 
  # model for this vertex
  model=glmer(value~Motion+Sex+EF+log(Scale)*Age+(1|bblid),data=mdf_verts)
  fe=fixef(model)
  re=ranef(model)
  re=re$bblid

  # pull out coefficients
  fEF=fe['EF']
  fMot=fe['Motion']
  fSex=fe['Sex']
  fAge=fe['Age']
  flSc=fe['log(Scale)']
  fIntrxn_lScAge=fe['log(Scale):Age']
  Intercept=fe['(Intercept)']

  # intercept correlated with Age?
  ageInt=cor.test(re$`(Intercept)`,df$Age,method='spearman')$estimate
  
  # coefficients into first row, along with age x Intercept corr.
  outarray[1,1]=fMot
  outarray[1,2]=fSex
  outarray[1,3]=fEF
  outarray[1,4]=flSc
  outarray[1,5]=fAge
  outarray[1,6]=fIntrxn_lScAge

  # hang on to yer bootstraps
  results <- boot(data=mdf_verts, statistic=returnLmCoefs, R=1000)
  # index 1 is intercept
  # index 2 is Motion
  outarray[2,1]=boot.ci(results,type="norm",index=2)$normal[2]
  outarray[3,1]=boot.ci(results,type="norm",index=2)$normal[3]
  # index 3 is Sex
  outarray[2,2]=boot.ci(results,type="norm",index=3)$normal[2]
  outarray[3,2]=boot.ci(results,type="norm",index=3)$normal[3]
  # index 4 is EF
  outarray[2,3]=boot.ci(results,type="norm",index=4)$normal[2]
  outarray[3,3]=boot.ci(results,type="norm",index=4)$normal[3]
  # index 5 is logScale
  outarray[2,4]=boot.ci(results,type="norm",index=5)$normal[2]
  outarray[3,4]=boot.ci(results,type="norm",index=5)$normal[3]
  # index 6 is Age
  outarray[2,5]=boot.ci(results,type="norm",index=6)$normal[3]
  outarray[3,5]=boot.ci(results,type="norm",index=6)$normal[3]
  # index 7 is age*logScale
  outarray[2,6]=boot.ci(results,type="norm",index=7)$normal[2]
  outarray[3,6]=boot.ci(results,type="norm",index=7)$normal[3]

  # no bootstrap equiv for int age correlation at the moment

  write.table(outarray,file=paste('~/mixedEffectModels/Modeled_fSex_fMot_fEF_fAgexScale_raInt_v',v,'_bwVals_BoStr_overScales.csv',sep=''),sep=',',row.names=F,quote=F)
  # 9/10/20 section to write out subject level intercepts and slopes
  #subjoutarray[,1]=df_verts$bblid
  #subjoutarray[,2]=re$`(Intercept)`
  #subjoutarray[,3]=re$`log(Scale)`
  #write.table(subjoutarray,file=paste('~/mixedEffectModels/Scales10thru20_subj_level_Modeled_fSca_fAge_fScaxAge_raScaS_raScaI_fM',v,'_bwVals_overScales.csv',sep=''),sep=',',row.names=F,quote=F)  
}
