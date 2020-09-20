library(reshape2)
library(lme4)
# this file has bblid, EF, Age, Motion, Sex. Was originally purposed for matlab (hence ML)
demoEF<-read.csv('~/forPMACS_EF.csv',header=F)
colnames(demoEF)<-c('scanid','bblid','EF','Age','Motion','Sex')
subjects<-read.csv('~/participants.txt',header = F)


colnames(subjects)<-c("scanid")
df<-merge(subjects,demoEF,by="scanid")

outputcolnames=c('Motion','Sex','EF','logScale','Age','logScale_x_Age')

outarray=matrix(1,nrow=1,ncol=6)
colnames(outarray)=outputcolnames
# 9/10/20 section to write out subject level intercepts and slopes
subjoutputcolnames=c('bblid','Intercept')
subjoutarray=matrix(1,nrow=693,ncol=2)
colnames(subjoutarray)=subjoutputcolnames
for (v in 1:17734){
  print(v)
  vFP=paste('~/mixedEffectModels/v',v,'_bwVals_overScales.csv',sep='')
  verts=read.csv(vFP)
  colnames(verts)[30]<-'bblid'
  df_verts<-merge(df,verts,by="bblid")
  mdf_verts<-melt(df_verts,id=c(1,2,3,4,5,6))
  mdf_verts$bblid<-as.factor(mdf_verts$bblid)
  colnames(mdf_verts)[7]<-c('Scale')
  mdf_verts$Scale<-as.integer(mdf_verts$Scale)
  mdf_verts$Age<-as.numeric(mdf_verts$Age)
  # FOR MAIN EFFECT OF EF - 9/20
  model=glmer(value~Motion+Sex+EF+log(Scale)*Age+(1|bblid),data=mdf_verts)
  fe=fixef(model)
  re=ranef(model)
  re=re$bblid
  avgSlope=fe['log(Scale):Age']
  avgInt=fe['(Intercept)']
  fMot=fe['Motion']
  fSex=fe['Sex']
  fEF=fe['EF']
  flSc=fe['logScale']
  fAge=fe['Age']
  fAgeInt=fe'log(Scale):Age']
  outarray[1]=fMot
  outarray[2]=fSex
  outarray[3]=fEF
  outarray[4]=flSc
  outarray[5]=fAge
  outarray[6]=fAgeInt
  write.table(outarray,file=paste('~/mixedEffectModels/Modeled_fMot_fSex_fEF_flSc_fAge_fAgeIntera_raInterc_v',v,'_bwVals_overScales.csv',sep=''),sep=',',row.names=F,quote=F)
}

