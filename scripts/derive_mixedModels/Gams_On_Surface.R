### for parallelizing over vertices, read in which vertex this should run on
v=commandArgs(trailingOnly=TRUE)
### load libraries
library(mgcv)
### read in data
df<-read.csv('TheFileYouWroteOutWithAllTheVerticesAndCovariates')
### initialize output
outputcolnames=c('s_Age','s_Scale','Motion','Sex')
outputrownames=c('CoefEstimate')
outarray=matrix(1,nrow=4,ncol=1)
colnames(outarray)=outputcolnames
rownames(outarray)=outputrownames
### convert the data into dataframe format
df<-data.frame(df)
# get coefficient estimates for this vertex, set this vertex's corresponding column name to "value" for gam to target
colnames(df)[v+3]<-"value"
model=gam(value~Motion+Sex+s(Scale,k=3,fx=T)+s(Age,k=3,fx=T),data=df)
gamsum=summary(model)
#### readout estimates: p.table is parametric coefs, s.table is smooths
# not sure if you want the t value or the estimate: they are both in the p.table
Motion_obs=gamsum$p.table['Motion','Estimate']
outarray['Coef','Motion']=Motion_obs
Sex_obs=gamsum$p.table['Sex','Estimate']
outarray['Coef','Sex']=Sex_obs
Scale_obs=gamsum$s.table['s(Scale)','F']
outarray['Coef','s_Scale']=Scale_obs
Age_obs=gamsum$s.table['s(Age)','F']
outarray['Coef','s_Age']=Age_obs

# change to whatever filename you want to organize this: make sure to keep "v" for aggregating these files in order later
write.table(outarray,file=paste('~/mixedEffectModels/Modeled_fSex_fMot_sScale_sAges_3fxT_raInt_v',v,'_bwVals_BoStr_overScales.csv',sep=''),sep=',',row.names=F,quote=F)
