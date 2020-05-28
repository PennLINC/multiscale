library(shapes)
library(ggplot2)
library(reshape2)
library(dplyr)
library(ggpubr)
library(vroom)
# load in demo
demo<-read.csv('/cbica/projects/pinesParcels/data/pnc_demo.csv')
age<-data.frame(demo$ageAtScan1,demo$scanid)
subjects<-read.csv('/cbica/projects/pinesParcels/data/participants.txt',header = F)
# Need to determine best qa file
##qa<-read.csv('~/Desktop/multiscale/n1601_RestQAData_20170318.csv')
colnames(subjects)<-c("scanid")
colnames(age)<-c("Age","scanid")
df<-merge(subjects,age,by="scanid")

behav<-read.csv('/cbica/projects/pinesParcels/dropbox/n693_Behavior_20181219.csv')

# community solutions guaged in this iteration
community_vec<-seq(2,30)

# load in error over scales
numiter=read.csv('/cbica/projects/pinesParcels/data/aggregated_data/iter_n',header = F)
iter_err=read.csv('/cbica/projects/pinesParcels/data/aggregated_data/iter_error',header = F)
recon_err=read.csv('/cbica/projects/pinesParcels/data/aggregated_data/recon_error',header=F)

# bblids got rounded in matlab csvwrite in this iteration, plug ids directly in
bblids<-read.delim('/cbica/projects/pinesParcels/data/bblids.txt',header=F)
# yes, I double checked that they matched up
numiter$V1<-bblids[,1]
iter_err$V1<-bblids[,1]
recon_err$V1<-bblids[,1]

# calculate difference
dfdif=iter_err
dfdif[,2:30]=iter_err[,2:30]-recon_err[2:30]

# get ages in there
ages<-data.frame(demo$ageAtScan1,demo$bblid)
colnames(ages)<-c("Age","bblid")

colnames(iter_err)[1]<-"bblid"
colnames(numiter)[1]<-"bblid"
colnames(recon_err)[1]<-"bblid"
colnames(dfdif)[1]<-"bblid"

df_tc<-merge(ages,iter_err,by="bblid")
df_ni<-merge(ages,numiter,by="bblid")
df_rc<-merge(ages,recon_err,by="bblid")
df_dif<-merge(ages,dfdif,by="bblid")

mdata<-melt(df_tc,id=c(1,2))
mdatani<-melt(df_ni,id=c(1,2))
mdatarc<-melt(df_rc,id=c(1,2))
mdatadif<-melt(df_dif,id=c(1,2))

tc<-ggplot(data=mdata,aes(x=variable,y=value,group=bblid,color=Age)) +geom_line(alpha = 0.15)+scale_color_gradientn(colors=c("yellow","purple")) + theme_dark()+labs(title="Total cost over scales")
ni<-ggplot(data=mdatani,aes(x=variable,y=value,group=bblid,color=Age)) +geom_line(alpha = 0.15)+scale_color_gradientn(colors=c("yellow","purple")) + theme_dark()+labs(title="Number of iterations over scales")
rc<-ggplot(data=mdatarc,aes(x=variable,y=value,group=bblid,color=Age)) +geom_line(alpha = 0.15)+scale_color_gradientn(colors=c("yellow","purple")) + theme_dark()+labs(title="Reconstruction error over scales")
dif<-ggplot(data=mdatadif,aes(x=variable,y=value,group=bblid,color=Age)) +geom_line(alpha = 0.15)+scale_color_gradientn(colors=c("yellow","purple")) + theme_dark()+labs(title="Non-recon error over scales")


ggarrange(tc,ni,dif,rc)

# load in FC features (takes about 3 minutes)
fc<-vroom('/cbica/projects/pinesParcels/results/aggregated_data/fc/master_fcfeats.csv')
# set colnames to matlab-printed colnames
colnames(fc)<-fc[1,]
# aaaand remove it
fc<-fc[-c(1),]

### merge FC with subj info
colnames(fc)[1]<-'bblid'
# AGE
masterdf<-merge(fc,demo,by='bblid')

# MOTION METRIC
# courtesty of ZC
# port over ##
Rest_Motion_Data <- read.csv("/cbica/projects/pinesParcels/data/n1601_RestQAData_20170714.csv")
NBack_Motion_Data <- read.csv("/cbica/projects/pinesParcels/data/n1601_NBACKQAData_20181001.csv")
Idemo_Motion_Data <- read.csv("/cbica/projects/pinesParcels/data/n1601_idemo_FinalQA_092817.csv")

Motion <- (Behavior$restRelMeanRMSMotion + Behavior$nbackRelMeanRMSMotion + Behavior$idemoRelMeanRMSMotion)/3;

# indicators of processing stream
###ind='ind'
###gro='gro'
###bts='bts'
###
#### indicators of fc feature type
###bwi='_bw_FC_'
###wini='_win_FC_'
###nsegi='_seg_scale'
###gsegi='_globseg_scale'
###
#### indices of said indicators
###indiv=grep(ind,colnames(df))
###group=grep(gro,colnames(df))
###basists=grep(bts,colnames(df))
###bwcol=grep(bwi,colnames(df))
###wincols=grep(wini,colnames(df))
###nsegcols=grep(nsegi,colnames(df))
###gsegcols=grep(gsegi,colnames(df))
###
# Make motion-regressed version of everything


# Plot error over scales
## error x scale color-coded age
## mean error x scale with SDs

# Plot gseg over scales
## gseg x scale color-coded age
## mean gseg x scale with SDs

# Plot correlations with age over scales (bw, win, seg)
# format into correlations_over_scalesplot format
###gseg<-data.frame(gsegcols)

###segdf<-merge(gseg,df,by="scanid")
###
###seg_cors<-matrix(0,length(community_vec),2)
###seg_cors[,1]<-community_vec
###
###for (i in 1:length(community_vec)){
###  # i+1 because first column is scanid
###  seg_cors[i,2]<-cor.test(segdf[,i+1],segdf$Age)$estimate
###}
###
###correlations_over_scalesplot(correlations=seg_cors,title="Segregation-Age correlations over Scales")

# multi-scale patterning
# shape analyses

### 29 scales, 2 coordinates (x,y), and 693 subjs
globalseg<-array(0,dim=c(29,2,693))

# for each subject, fill in x and y coords. (x is constant, is scale)
for (i in 1:693){
  # 2-30 as x-axis (scales of obs.)
  globalseg[,1,i]<-seq(2,30)
  # y values as error/cost
  # seems more matlabby than characteristic of R that I have to as.x(as.x(df)) for it to work, but here we are
  globalseg[,2,i]<-as.array(as.matrix(segmat[i,2:30]))
  
  # scale SDs to be equiv in x and y dimensions (to enforce principled shape)
  sd1<-(sd(globalseg[,1,i]))
  sd2<-(sd(globalseg[,2,i]))
  globalseg[,1,i]<- globalseg[,1,i] * sd2
  globalseg[,2,i]<- globalseg[,2,i] * sd1
  
}

seg_procrust<-procGPA(globalseg)

shapepca(seg_procrust, pcno=1, type = "v", mag=5)

# get individ. level pc scores into df
df_tc$pc1<-seg_procrust$scores[,1]

## plot demonstrative subjs (highest and lowest PC loading)
### is shape capture by slope of line (gradual descent with younger folks?)

### explore regional subtrates of revealed effects