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

outputcolnames=c('logScale_x_age','avgInt','ageSlope','ageInt','MotionFixedEF')
outarray=matrix(1,nrow=1,ncol=5)
colnames(outarray)=outputcolnames
# 9/10/20 section to write out subject level intercepts and slopes
subjoutputcolnames=c('bblid','Intercept','Slope')
subjoutarray=matrix(1,nrow=693,ncol=3)
colnames(subjoutarray)=subjoutputcolnames
for (v in 1:17734){
  print(v)
  vFP=paste('~/mixedEffectModels/v',v,'_bwVals_overScales.csv',sep='')
  verts=read.csv(vFP)
  colnames(verts)[30]<-'bblid'
  df_verts<-merge(df,verts,by="bblid")
  mdf_verts<-melt(df_verts,id=c(1,2,3,4,5))
  mdf_verts$bblid<-as.factor(mdf_verts$bblid)
  colnames(mdf_verts)[6]<-c('Scale')
  mdf_verts$Scale<-as.integer(mdf_verts$Scale)
  mdf_verts$Age<-as.numeric(mdf_verts$Age)
  model=glmer(value~Motion+log(Scale)*Age+(log(Scale)|bblid),data=mdf_verts)
  fe=fixef(model)
  re=ranef(model)
  re=re$bblid
  avgSlope=fe['log(Scale):Age']
  avgInt=fe['(Intercept)']
  avgMot=fe['Motion']
  ageSlope=cor.test(re$`log(Scale)`,df$Age,method='spearman')$estimate
  ageInt=cor.test(re$`(Intercept)`,df$Age,method='spearman')$estimate
  outarray[1]=avgSlope
  outarray[2]=avgInt
  outarray[3]=ageSlope
  outarray[4]=ageInt
  outarray[5]=avgMot
  write.table(outarray,file=paste('~/mixedEffectModels/Modeled_fSca_fAge_fScaxAge_raScaS_raScaI_fM_v',v,'_bwVals_overScales.csv',sep=''),sep=',',row.names=F,quote=F)
  # 9/10/20 section to write out subject level intercepts and slopes
  subjoutarray[,1]=df_verts$bblid
  subjoutarray[,2]=re$`(Intercept)`
  subjoutarray[,3]=re$`log(Scale)`
  write.table(subjoutarray,file=paste('~/mixedEffectModels/subj_level_Modeled_fSca_fAge_fScaxAge_raScaS_raScaI_fM',v,'_bwVals_overScales.csv',sep=''),sep=',',row.names=F,quote=F)
}