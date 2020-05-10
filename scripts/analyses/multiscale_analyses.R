library(shapes)
library(ggplot2)
library(reshape2)
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
numiter=read.csv('/cbica/projects/pinesParcels/data/aggregated_data/iter_n.csv')
iter_err=read.csv('/cbica/projects/pinesParcels/data/aggregated_data/iter_error.csv')
# load in FC features
fc<-read.csv('/cbica/projects/pinesParcels/results/aggregated_data/fc/master_fcfeats.csv')

# merge FC with subj info

# indicators of processing stream
ind='ind'
gro='gro'
bts='bts'

# indicators of fc feature type
bwi='_bw_FC_'
wini='_win_FC_'
nsegi='_seg_scale'
gsegi='_globseg_scale'

# indices of said indicators
indiv=grep(ind,colnames(df))
group=grep(gro,colnames(df))
basists=grep(bts,colnames(df))
bwcol=grep(bwi,colnames(df))
wincols=grep(wini,colnames(df))
nsegcols=grep(nsegi,colnames(df))
gsegcols=grep(gsegi,colnames(df))

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
## riemmanian COM alignment
## shape PCA
## shape PC1 cor w/ age
## plot demonstrative subjs (highest and lowest PC loading)
### is shape capture by slope of line (gradual descent with younger folks?)

### explore regional subtrates of revealed effects