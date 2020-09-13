# ran on all vertices on pmacs with r 3.6.3 on sept 13th 2020 - no random effects in this version
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

#######outputcolnames=c('avgSlope','avgInt','ageSlope','ageInt','MotionFixedEF')
outputcolnames=c('ageCoef','logScaleCoef','ageScaleIntCoef','motionCoef','sexCoef')
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
  ###### 9/13 - fixed effects only model
  model=lm(value~Age*log(Scale)+Motion+Sex,data=mdf_verts)
  ######model=glmer(value~Motion+log(Scale)+(1 + log(Scale)|bblid),data=mdf_verts[1:6930,])
  ######fe=fixef(model)
  ######re=ranef(model)
  ######re=re$bblid
  ######avgSlope=fe['log(Scale)']
  ageCoef=model$coefficients['Age']
  logScaleCoef=model$coefficients['log(Scale)']
  ageScaleIntCoef=model$coefficients['Age:log(Scale)']
  motionCoef=model$coefficients['Motion']
  sexCoef=model$coefficients['Sex2']
  ######avgInt=fe['(Intercept)']
  ######avgMot=fe['Motion']
  ######ageSlope=cor.test(re$`log(Scale)`,df$Age,method='spearman')$estimate
  ######ageInt=cor.test(re$`(Intercept)`,df$Age,method='spearman')$estimate
  ######outarray[1]=avgSlope
  ######outarray[2]=avgInt
  ######outarray[3]=ageSlope
  ######outarray[4]=ageInt
  ######outarray[5]=avgMot
  outarray[1]=ageCoef
  outarray[2]=logScaleCoef
  outarray[3]=ageScaleIntCoef
  outarray[4]=motionCoef
  outarray[5]=sexCoef
  write.table(outarray,file=paste('~/mixedEffectModels/Modeled_fAge_flSc_fMot_fSex_fMot_v',v,'_bwVals_overScales.csv',sep=''),sep=',',row.names=F,quote=F)
  # 9/10/20 section to write out subject level intercepts and slopes
  #######subjoutarray[,1]=df_verts$bblid
  #######subjoutarray[,2]=re$`(Intercept)`
  #######subjoutarray[,3]=re$`log(Scale)`
  #write.table(subjoutarray,file=paste('~/mixedEffectModels/subj_level_Modeled_fS_fI_raS_raI_fM_v',v,'_bwVals_overScales.csv',sep=''),sep=',',row.names=F,quote=F)  
}
