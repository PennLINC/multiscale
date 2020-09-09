.libPaths('/cbica/projects/pinesParcels/R')
library(reshape2)
library(lme4)
demo<-read.csv('/cbica/projects/pinesParcels/data/pnc_demo.csv')
ageSex<-data.frame(demo$ageAtScan1,as.factor(demo$sex),demo$scanid,demo$bblid)
subjects<-read.csv('/cbica/projects/pinesParcels/data/participants.txt',header = F)
colnames(ageSex)[4]<-'bblid'
colnames(ageSex)[1]<-'Age'
Rest_Motion_Data <- read.csv("/cbica/projects/pinesParcels/data/n1601_RestQAData_20170714.csv")
NBack_Motion_Data <- read.csv("/cbica/projects/pinesParcels/data/n1601_NBACKQAData_20181001.csv")
Idemo_Motion_Data <- read.csv("/cbica/projects/pinesParcels/data/n1601_idemo_FinalQA_092817.csv")
motmerge<-merge(Rest_Motion_Data,NBack_Motion_Data,by='bblid')
motmerge<-merge(motmerge,Idemo_Motion_Data,by='bblid')
motmerge$Motion <- (motmerge$restRelMeanRMSMotion + motmerge$nbackRelMeanRMSMotion + motmerge$idemoRelMeanRMSMotion)/3;
motiondf<-data.frame(motmerge$bblid,motmerge$Motion)
colnames(motiondf)<-c('bblid','Motion')
colnames(subjects)<-c("scanid")
colnames(ageSex)<-c("Age","Sex","scanid","bblid")
df<-merge(subjects,ageSex,by="scanid")
df<-merge(df,motiondf,by='bblid')

outputcolnames=c('avgSlope','avgInt','ageSlope','ageInt')
outarray=matrix(1,nrow=1,ncol=4)
colnames(outarray)=outputcolnames

for (v in 1:17734){
  print(v)
  vFP=paste('/cbica/projects/pinesParcels/results/mixedEffectModels/v',v,'_bwVals_overScales.csv',sep='')
  verts=read.csv(vFP)
  colnames(verts)[30]<-'bblid'
  df_verts<-merge(df,verts,by="bblid")
  mdf_verts<-melt(df_verts,id=c(1,2,3,4,5))
  mdf_verts$bblid<-as.factor(mdf_verts$bblid)
  colnames(mdf_verts)[6]<-c('Scale')
  mdf_verts$Scale<-as.integer(mdf_verts$Scale)
  mdf_verts$Age<-as.numeric(mdf_verts$Age)
  model=glmer(value~Motion+log(Scale)+(1 + log(Scale)|bblid),data=mdf_verts)
  fe=fixef(model)
  re=ranef(model)
  re=re$bblid
  avgSlope=fe['log(Scale)']
  avgInt=fe['(Intercept)']
  ageSlope=cor.test(re$`log(Scale)`,df$Age,method='spearman')$estimate
  ageInt=cor.test(re$`(Intercept)`,df$Age,method='spearman')$estimate
  outarray[1]=avgSlope
  outarray[2]=avgInt
  outarray[3]=ageSlope
  outarray[4]=ageInt
  write.csv(outarray,file=paste('/cbica/projects/pinesParcels/results/mixedEffectModels/Modeled_v',v,'_bwVals_overScales.csv',sep=''))
}