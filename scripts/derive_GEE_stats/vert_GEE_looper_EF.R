### THANK YOU SARAH!!!

v=commandArgs(trailingOnly=TRUE)
library(reshape2)
library(mgcv)
library(geepack)
library(doBy)
library(MASS)

# this file has bblid, EF, Age, Motion, Sex. Was originally purposed for matlab (hence ML)
demoEF<-read.csv('~/forPMACS_EF.csv',header=F)
colnames(demoEF)<-c('scanid','bblid','EF','Age','Motion','Sex')
subjects<-read.csv('~/participants.txt',header = F)

# set colnames for proc. df
colnames(subjects)<-c("scanid")
df<-merge(subjects,demoEF,by="scanid")

# initialize output table
outputrownames=c('Coef','p')
varVector=c('s_Age','s_Scale','s_EF','AgeXScale','EFxScale','Motion','Sex')
outputcolnames=varVector
# make a vector to correspond with L_contrast: smooths x2 (under k=3 modeling) and interactions get another x2
L_contrast_matcher=c('Intercept','s_Age','s_Age','s_Scale','s_Scale','s_EF','s_EF','AgeXScale','AgeXScale','AgeXScale','AgeXScale','EFxScale','EFxScale','EFxScale','EFxScale','Motion','Sex')
outarray=matrix(1,nrow=2,ncol=7)
colnames(outarray)=outputcolnames
rownames(outarray)=outputrownames

print(v)

##################

# wrangle data, get variables into approp. var type (mixed effect filepath outdated)
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


# only hitting EF(3) and EFxScale(5) with this script: age and agexscale will be modeled independently of EF in another script
for (i in c(3,5)){
	variable_i<-varVector[i]
	# 0's correspond to coefficients where variable is included in both the full and reduced model
	# 1's correspond to coefficients that we want to test (jointly) if = 0
	# 2 linear effects + 3 smooths (x2) + 2 smooth interactions (x4) (+1 for intercept?) = length 17 contrast vector
	L_contrast = rep(0,17)
	# set up L_contrast to test this particular variable
	L_conInd=which(L_contrast_matcher==variable_i)
	L_contrast[L_conInd]=1
	# fit the gam (no mixed effects)
	fit_gam=mgcv::gam(value~Motion+Sex+s(Scale,k=3,fx=T)+s(Age,k=3,fx=T)+s(EF,k=3,fx=T)+ti(Scale,Age,k=3,fx=T)+ti(Scale,EF,k=3,fx=T),data=mdf_verts)
	# extract model matrix from GAM and then input the smooth terms to a gee (assuming exchangeable correlation structure)
	gam.model.matrix = cbind(model.matrix(fit_gam), bblid = mdf_verts$bblid, value = mdf_verts$value)
	gam.model.df = data.frame(gam.model.matrix)
	gam.model.df = gam.model.df[order(gam.model.df$bblid),] # sort by ID for geeglm
	# doing the rest with a geeglm will give robust variance estimators, accounting for within-subject
	# correlation which was not the case in the gam part of the output from GAMM when we were doing bootstrapping
	fit_gee = geepack::geeglm(value~ s.Age..1 + s.Age..2 + 
			      s.Scale..1 + s.Scale..2 +
			      s.EF..1 + s.EF..2 +
                              ti.Scale.Age..1 + ti.Scale.Age..2 + ti.Scale.Age..3 +
                              ti.Scale.Age..4 + ti.Scale.EF..1 + ti.Scale.EF..2 + ti.Scale.EF..3 +
			      ti.Scale.EF..4 + Motion + Sex2, id = gam.model.df$bblid,
                            data = gam.model.df, corstr = "exchangeable")
  	# test of whether the coefficients corresponding to a `1` in L_contrast differ from 0
 	test = doBy::esticon(obj = fit_gee,L = L_contrast,joint.test = T)
  	# p-value based on chi-square with 1 df
  	pvalX2 = pchisq(test$X2.stat, df = 1, lower.tail = F)
	# writeout out chi-square coef and pval for this variable
	outarray['Coef',variable_i]=test$X2.stat
	outarray['p',variable_i]=pvalX2
}

write.table(outarray,file=paste('~/mixedEffectModels/Modeled_GEE_Sex_Mot_s3fxT_AgexScale_EFxScale_v',v,'_bwVals_overScales.csv',sep=''),sep=',',row.names=F,quote=F)

