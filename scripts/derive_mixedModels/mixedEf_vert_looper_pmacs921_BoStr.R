
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

outputcolnames=c('Age','logScale','AgeXlogScale','Motion','Sex','ageInt')
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
  model=glmer(value~Motion+Sex+log(Scale)*Age+(1|bblid),data=d2)
  return(fixef(model))
}

for (v in 1:17734){
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
  model=glmer(value~Motion+Sex+log(Scale)*Age+(1|bblid),data=mdf_verts)
  fe=fixef(model)
  re=ranef(model)
  re=re$bblid

  # pull out coefficients
  fMot=fe['Motion']
  fSex=fe['Sex']
  fAge=fe['Age']
  flSc=fe['log(Scale)']
  fIntrxn=fe['log(Scale):Age']
  Intercept=fe['(Intercept)']

  # intercept correlated with Age?
  ageInt=cor.test(re$`(Intercept)`,df$Age,method='spearman')$estimate
  
  # coefficients into first row, along with age x Intercept corr.
  outarray[1,1]=fAge
  outarray[1,2]=flSc
  outarray[1,3]=fIntrxn
  outarray[1,4]=fMot
  outarray[1,5]=fSex
  outarray[1,6]=ageInt

  # hang on to yer bootstraps
  results <- boot(data=mdf_verts, statistic=returnLmCoefs, R=1000)
  # index 1 is intercept
  # index 2 is Motion
  outarray[2,4]=boot.ci(results,type="norm",index=2)$normal[2]
  outarray[3,4]=boot.ci(results,type="norm",index=2)$normal[3]
  # index 3 is Sex
  outarray[2,5]=boot.ci(results,type="norm",index=3)$normal[2]
  outarray[3,5]=boot.ci(results,type="norm",index=3)$normal[3]
  # index 4 is logScale
  outarray[2,2]=boot.ci(results,type="norm",index=4)$normal[2]
  outarray[3,2]=boot.ci(results,type="norm",index=4)$normal[3]
  # index 5 is Age
  outarray[2,1]=boot.ci(results,type="norm",index=5)$normal[2]
  outarray[3,1]=boot.ci(results,type="norm",index=5)$normal[3]
  # index 6 is age*logScale
  outarray[2,3]=boot.ci(results,type="norm",index=6)$normal[2]
  outarray[3,3]=boot.ci(results,type="norm",index=6)$normal[3]


  # no bootstrap equiv for int age correlation at the moment

  write.table(outarray,file=paste('~/mixedEffectModels/Modeled_fSex_fMot_fAgexScale_raInt_v',v,'_bwVals_BoStr_overScales.csv',sep=''),sep=',',row.names=F,quote=F)
  # 9/10/20 section to write out subject level intercepts and slopes
  #subjoutarray[,1]=df_verts$bblid
  #subjoutarray[,2]=re$`(Intercept)`
  #subjoutarray[,3]=re$`log(Scale)`
  #write.table(subjoutarray,file=paste('~/mixedEffectModels/Scales10thru20_subj_level_Modeled_fSca_fAge_fScaxAge_raScaS_raScaI_fM',v,'_bwVals_overScales.csv',sep=''),sep=',',row.names=F,quote=F)  
}
