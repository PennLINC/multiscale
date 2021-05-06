library(vroom)

# load in demographics
demo<-read.csv('/cbica/projects/pinesParcels/data/pnc_demo.csv')
ageSex<-data.frame(demo$ageAtScan1,as.factor(demo$sex),demo$scanid,demo$bblid)
subjects<-read.csv('/cbica/projects/pinesParcels/data/participants.txt',header = F)

# load in head motion data
Rest_Motion_Data <- read.csv("/cbica/projects/pinesParcels/data/n1601_RestQAData_20170714.csv")
NBack_Motion_Data <- read.csv("/cbica/projects/pinesParcels/data/n1601_NBACKQAData_20181001.csv")
Idemo_Motion_Data <- read.csv("/cbica/projects/pinesParcels/data/n1601_idemo_FinalQA_092817.csv")

# aggregate motion metrics
motmerge<-merge(Rest_Motion_Data,NBack_Motion_Data,by='bblid')
motmerge<-merge(motmerge,Idemo_Motion_Data,by='bblid')
motmerge$Motion <- (motmerge$restRelMeanRMSMotion + motmerge$nbackRelMeanRMSMotion + motmerge$idemoRelMeanRMSMotion)/3;
motiondf<-data.frame(motmerge$bblid,motmerge$Motion)

# set column names
colnames(motiondf)<-c('bblid','Motion')
colnames(subjects)<-c("scanid")
colnames(ageSex)<-c("Age","Sex","scanid","bblid")
df<-merge(subjects,ageSex,by="scanid")
df<-merge(df,motiondf,by='bblid')

# match with FC data for consistency with other R loads/processes 
fc<-vroom('/cbica/projects/pinesParcels/results/aggregated_data/fc/master_fcfeats_rounded.csv')

# take out row number row
fc<-fc[-c(1)]

# isolate shams (although merge should take them out later)
shams<-fc[694:695,]

# save out for vertex-level age modeling
masterdf<-merge(fc,df,by='bblid')

forMLpc<-cbind(masterdf$bblid,masterdf$Age,masterdf$Motion,masterdf$Sex)
MPpcFN<-'/cbica/projects/pinesParcels/results/EffectVecs/forMLpc.csv'
write.table(forMLpc,MPpcFN,row.names = F,col.names = F,sep = ',')

# Now load in executive function for sep. writeout
subjbehav<-read.csv("~/Downloads/n9498_cnb_factor_scores_fr_20170202.csv")
ef<-data.frame(subjbehav$NAR_F1_Exec_Comp_Cog_Accuracy,subjbehav$bblid)
# leave column name for matching prior selection code
colnames(ef)<-c('F1_Exec_Comp_Cog_Accuracy','bblid')
# merge in
masteref<-merge(masterdf,ef,by='bblid')


### save out for vertex-level EF modeling
# sc same as scanid
forPMACS_EF<-cbind(masteref$sc,masteref$bblid,masteref$F1_Exec_Comp_Cog_Accuracy,masteref$Age,masteref$Motion,masteref$Sex)
MP_EFFN<-'/cbica/projects/pinesParcels/results/EffectVecs/forPMACS_EF.csv'
write.table(forPMACS_EF,MP_EFFN,row.names = F,col.names = F,sep = ',')
