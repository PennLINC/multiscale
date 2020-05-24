library(shapes)
library(ggplot2)
library(reshape2)
library(dplyr)
library(ggpubr)
# load in demo
demo<-read.csv('/cbica/projects/pinesParcels/data/pnc_demo.csv')
age<-data.frame(demo$ageAtScan1,demo$scanid)
subjects<-read.csv('/cbica/projects/pinesParcels/data/participants.txt',header = F)
# Need to determine best qa file
##qa<-read.csv('~/Desktop/multiscale/n1601_RestQAData_20170318.csv')
colnames(subjects)<-c("scanid")
colnames(age)<-c("Age","scanid")
df<-merge(subjects,age,by="scanid")

# community solutions guaged in this iteration
community_vec<-seq(2,30)

# load in error over scales
numiter=read.csv('/cbica/projects/pinesParcels/data/aggregated_data/iter_n',header = F)
iter_err=read.csv('/cbica/projects/pinesParcels/data/aggregated_data/iter_error',header = F)
recon_err=read.csv('/cbica/projects/pinesParcels/data/aggregated_data/recon_error',header=F)
# plot first five subjects' itererr
df=iter_err[,1:30]
dfni=numiter[,1:30]
dfrc=recon_err[,1:30]

# calculate difference
dfdif=df
dfdif[,2:30]=dfdif[,2:30]-dfrc[2:30]

# get ages in there
ages<-data.frame(demo$ageAtScan1,demo$bblid)
colnames(ages)<-c("Age","scanid")

colnames(df)[1]<-"scanid"
colnames(dfni)[1]<-"scanid"
colnames(dfrc)[1]<-"scanid"
colnames(dfdif)[1]<-"scanid"

df_tc<-merge(ages,df,by="scanid")
df_ni<-merge(ages,dfni,by="scanid")
df_rc<-merge(ages,dfrc,by="scanid")
df_dif<-merge(ages,dfdif,by="scanid")

mdata<-melt(df_tc,id=c(1,2))
mdatani<-melt(df_ni,id=c(1,2))
mdatarc<-melt(df_rc,id=c(1,2))
mdatadif<-melt(df_dif,id=c(1,2))

tc<-ggplot(data=mdata,aes(x=variable,y=value,group=scanid,color=Age)) +geom_line(alpha = 0.4)+scale_color_gradientn(colors=c("yellow","purple")) + theme_dark()+labs(title="Total cost over scales")
ni<-ggplot(data=mdatani,aes(x=variable,y=value,group=scanid,color=Age)) +geom_line(alpha = 0.4)+scale_color_gradientn(colors=c("yellow","purple")) + theme_dark()+labs(title="Number of iterations over scales")
rc<-ggplot(data=mdatarc,aes(x=variable,y=value,group=scanid,color=Age)) +geom_line(alpha = 0.4)+scale_color_gradientn(colors=c("yellow","purple")) + theme_dark()+labs(title="Reconstruction error over scales")
dif<-ggplot(data=mdatadif,aes(x=variable,y=value,group=scanid,color=Age)) +geom_line(alpha = 0.4)+scale_color_gradientn(colors=c("yellow","purple")) + theme_dark()+labs(title="Non-recon error over scales")


ggarrange(tc,ni,dif,rc)

# load in FC features
###fc<-read.csv('/cbica/projects/pinesParcels/results/aggregated_data/fc/master_fcfeats.csv')

# merge FC with subj info

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
gseg<-data.frame(gsegcols)

segdf<-merge(gseg,df,by="scanid")

seg_cors<-matrix(0,length(community_vec),2)
seg_cors[,1]<-community_vec

for (i in 1:length(community_vec)){
  # i+1 because first column is scanid
  seg_cors[i,2]<-cor.test(segdf[,i+1],segdf$Age)$estimate
}

correlations_over_scalesplot(correlations=seg_cors,title="Segregation-Age correlations over Scales")

# multi-scale patterning
# shape analyses

### 29 scales, 2 coordinates (x,y), and 693 subjs
totalcost<-array(0,dim=c(29,2,693))
recon<-array(0,dim=c(29,2,693))

# for each subject, fill in x and y coords. (x is constant, is scale)
for (i in 1:693){
  # 2-29 as x-axis (scales of obs.)
  totalcost[,1,i]<-seq(2,30)
  recon[,1,i]<-seq(2,30)
  # y values as error/cost
  # seems more matlabby than characteristic of R that I have to as.x(as.x(df)) for it to work, but here we are
  totalcost[,2,i]<-as.array(as.matrix(df[i,2:30]))
  recon[,2,i]<-as.array(as.matrix(dfrc[i,2:30]))
  
  # scale SDs to be equiv in x and y dimensions (to enforce principled shape)
  sd1<-(sd(totalcost[,1,i]))
  sd2<-(sd(recon[,2,i]))
  totalcost[,1,i]<- totalcost[,1,i] * sd2
  totalcost[,2,i]<- totalcost[,2,i] * sd1
  sd1<-(sd(recon[,1,i]))
  sd2<-(sd(recon[,2,i]))
  recon[,1,i]<- recon[,1,i] * sd2
  recon[,2,i]<- recon[,2,i] * sd1
  
}
tc_procrust<-procGPA(totalcost,scale = F)
rc_procrust<-procGPA(recon,scale = F)

shapepca(tc_procrust, pcno=1, type = "v", mag=3)
shapepca(rc_procrust, pcno=1, type = "v", mag=3)



## plot demonstrative subjs (highest and lowest PC loading)
### is shape capture by slope of line (gradual descent with younger folks?)

### explore regional subtrates of revealed effects