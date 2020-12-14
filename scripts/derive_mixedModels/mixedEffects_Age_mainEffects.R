### for parallelizing over vertices, read in which vertex this should run on
v=commandArgs(trailingOnly=TRUE)
set.seed(1)

### load libraries
library(mgcv)
library(boot)
library(reshape2)
library(lme4)

### read in data
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
### calculate appropriate motion metric
motmerge$Motion <- (motmerge$restRelMeanRMSMotion + motmerge$nbackRelMeanRMSMotion + motmerge$idemoRelMeanRMSMotion)/3;
motiondf<-data.frame(motmerge$bblid,motmerge$Motion)
### rename and merge
colnames(motiondf)<-c('bblid','Motion')
colnames(subjects)<-c("scanid")
colnames(ageSex)<-c("Age","Sex","scanid","bblid")
df<-merge(subjects,ageSex,by="scanid")
df<-merge(df,motiondf,by='bblid')
### read in vertex-level data and wrangle using input 'v' argument
vFP=paste('~/mixedEffectModels/v',v,'_bwVals_overScales.csv',sep='')
verts=read.csv(vFP)
colnames(verts)[30]<-'bblid'
df_verts<-merge(df,verts,by="bblid")
mdf_verts<-melt(df_verts,id=c(1,2,3,4,5))
mdf_verts$bblid<-as.factor(mdf_verts$bblid)
# +1 because it stats at K=1 (shift to real start at 2)
colnames(mdf_verts)[6]<-c('Scale')+1
mdf_verts$Scale<-as.integer(mdf_verts$Scale)
mdf_verts$Sex<-as.factor(mdf_verts$Sex)
mdf_verts$Age<-as.numeric(mdf_verts$Age)

### initialize output (change for continuous p-val, +1 row)
### MAIN EFFECTS VERSION - ADD INTERACTIONS FOR INTERACTION VERSIONS
outputcolnames=c('s_Age','s_Scale','Motion','Sex')
outputrownames=c('Coef','BoStrCI_Low','BoStrCI_Upp','StudentizedP')
outarray=matrix(1,nrow=4,ncol=4)
colnames(outarray)=outputcolnames
rownames(outarray)=outputrownames

# get initial coefficient estimate
model=gamm(value~Motion+Sex+s(Scale,k=3,fx=T)+s(Age,k=3,fx=T),random=list(bblid=~1),data=mdf_verts)
gammsum=summary(model$gam)
gammtable=gammsum$s.table
fe=fixef(model$lme)
#### readout estimates as respective _obs's
Motion_obs=fe['XMotion']
outarray['Coef','Motion']=Motion_obs
Sex_obs=fe['XSex2']
outarray['Coef','Sex']=Sex_obs
Scale_obs=gammtable['s(Scale)','F']
outarray['Coef','s_Scale']=Scale_obs
Age_obs=gammtable['s(Age)','F']
outarray['Coef','s_Age']=Age_obs

########### 12/12/20 - bootstrap section amendment to use Sarah's code
# getting a p-value by inverting bootstrap confidence interval
# orig bootstrapping from Sarah Weinstein 12/07/2020
# Studentized bootstrap confidence interval:
# based on Section 2 from https://www.stat.cmu.edu/~ryantibs/advmethods/notes/bootstrap.pdf

NumberOfSubjects=693

B = 1000 # number of bootstraps (slow if you do both the inner and outer bootstrap loops)
# initialize vectors where certain output will be saved
Motion_b = vector(mode = "numeric", length = B)
Sex_b = vector(mode = "numeric", length = B)
Scale_b = vector(mode = "numeric", length = B)
Age_b = vector(mode = "numeric", length = B)

for (b in 1:B){
  print(paste(b,' out of ',B))
  # bootstrap sample
  resample_rows = sample(seq(1:NumberOfSubjects), NumberOfSubjects, replace = T)
  data_resamp = df_verts[resample_rows,]
  # melt it back into submission 
  mdf_verts<-melt(data_resamp,id=c(1,2,3,4,5))
  mdf_verts$bblid<-as.factor(mdf_verts$bblid)
  colnames(mdf_verts)[6]<-c('Scale')
  mdf_verts$Scale<-as.integer(mdf_verts$Scale)
  mdf_verts$Sex<-as.factor(mdf_verts$Sex)
  mdf_verts$Age<-as.numeric(mdf_verts$Age)
  # rerun model
  model=gamm(value~Motion+Sex+s(Scale,k=3,fx=T)+s(Age,k=3,fx=T),random=list(bblid=~1),data=mdf_verts)
  #### readout estimates
  gammsum=summary(model$gam)
  gammtable=gammsum$s.table
  fe=fixef(model$lme)
  Motion_b[b]=fe['XMotion']
  Sex_b[b]=fe['XSex2']
  Scale_b[b]=gammtable['s(Scale)','F']
  Age_b[b]=gammtable['s(Age)','F']
  
}

Motion_CI_bound1 = Motion_obs - 1.96*sqrt(var(Motion_b)/length(Motion_b))
Motion_CI_bound2 = Motion_obs + 1.96*sqrt(var(Motion_b)/length(Motion_b))
outarray['BoStrCI_Low','Motion']=Motion_CI_bound1
outarray['BoStrCI_Upp','Motion']=Motion_CI_bound2
# now do the studentized p val calculation
if (Motion_CI_bound1 > 0 | Motion_CI_bound2 > 0){
  pval = 2*pnorm(max(Motion_CI_bound1, Motion_CI_bound2), lower.tail = F) # getting the area above the upper bound of the CI
} else {
  pval = 2*pnorm(min(Motion_CI_bound1, Motion_CI_bound2), lower.tail = T) # getting the area below the lower bound of the CI
}
outarray['StudentizedP','Motion']<-pval

Sex_CI_bound1 = Sex_obs - 1.96*sqrt(var(Sex_b)/length(Sex_b))
Sex_CI_bound2 = Sex_obs + 1.96*sqrt(var(Sex_b)/length(Sex_b))
outarray['BoStrCI_Low','Sex']=Sex_CI_bound1
outarray['BoStrCI_Upp','Sex']=Sex_CI_bound2
# now do the studentized p val calculation
if (Sex_CI_bound1 > 0 | Sex_CI_bound2 > 0){
  pval = 2*pnorm(max(Sex_CI_bound1, Sex_CI_bound2), lower.tail = F) # getting the area above the upper bound of the CI
} else {
  pval = 2*pnorm(min(Sex_CI_bound1, Sex_CI_bound2), lower.tail = T) # getting the area below the lower bound of the CI
}
outarray['StudentizedP','Sex']<-pval

Scale_CI_bound1 = Scale_obs - 1.96*sqrt(var(Scale_b)/length(Scale_b))
Scale_CI_bound2 = Scale_obs + 1.96*sqrt(var(Scale_b)/length(Scale_b))
outarray['BoStrCI_Low','s_Scale']=Scale_CI_bound1
outarray['BoStrCI_Upp','s_Scale']=Scale_CI_bound2
# now do the studentized p val calculation
if (Scale_CI_bound1 > 0 | Scale_CI_bound2 > 0){
  pval = 2*pnorm(max(Scale_CI_bound1, Scale_CI_bound2), lower.tail = F) # getting the area above the upper bound of the CI
} else {
  pval = 2*pnorm(min(Scale_CI_bound1, Scale_CI_bound2), lower.tail = T) # getting the area below the lower bound of the CI
}
outarray['StudentizedP','s_Scale']<-pval

Age_CI_bound1 = Age_obs - 1.96*sqrt(var(Age_b)/length(Age_b))
Age_CI_bound2 = Age_obs + 1.96*sqrt(var(Age_b)/length(Age_b))
outarray['BoStrCI_Low','s_Age']=Age_CI_bound1
outarray['BoStrCI_Upp','s_Age']=Age_CI_bound2
# now do the studentized p val calculation
if (Age_CI_bound1 > 0 | Age_CI_bound2 > 0){
  pval = 2*pnorm(max(Age_CI_bound1, Age_CI_bound2), lower.tail = F) # getting the area above the upper bound of the CI
} else {
  pval = 2*pnorm(min(Age_CI_bound1, Age_CI_bound2), lower.tail = T) # getting the area below the lower bound of the CI
}
outarray['StudentizedP','s_Age']<-pval

write.table(outarray,file=paste('~/mixedEffectModels/Modeled_fSex_fMot_sScale_sAges_3fxT_raInt_v',v,'_bwVals_BoStr_overScales.csv',sep=''),sep=',',row.names=F,quote=F)