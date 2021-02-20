
# iteration number, probz will split this into 10 jobs. set seed as iteration number for different bootstraps
iter=commandArgs(trailingOnly=TRUE)

#libraries


library(mediation)
library(gratia)
library(ggplot2)
library(reshape2)
library(dplyr)
library(ggpubr)
library(vroom)
library(data.table)
library(mgcv)
library(ppcor)
library(viridis)

# load 'erry thang



### load in demograhics
demo<-read.csv('/cbica/projects/pinesParcels/data/pnc_demo.csv')
ageSex<-data.frame(demo$ageAtScan1,as.factor(demo$sex),demo$scanid,demo$bblid)
subjects<-read.csv('/cbica/projects/pinesParcels/data/participants.txt',header = F)

### Collapse Motion metric 
# read in
Rest_Motion_Data <- read.csv("/cbica/projects/pinesParcels/data/n1601_RestQAData_20170714.csv")
NBack_Motion_Data <- read.csv("/cbica/projects/pinesParcels/data/n1601_NBACKQAData_20181001.csv")
Idemo_Motion_Data <- read.csv("/cbica/projects/pinesParcels/data/n1601_idemo_FinalQA_092817.csv")
# combine
motmerge<-merge(Rest_Motion_Data,NBack_Motion_Data,by='bblid')
motmerge<-merge(motmerge,Idemo_Motion_Data,by='bblid')
motmerge$Motion <- (motmerge$restRelMeanRMSMotion + motmerge$nbackRelMeanRMSMotion + motmerge$idemoRelMeanRMSMotion)/3;
motiondf<-data.frame(motmerge$bblid,motmerge$Motion)
colnames(motiondf)<-c('bblid','Motion')

### combine non-fMR data
colnames(subjects)<-c("scanid")
colnames(ageSex)<-c("Age","Sex","scanid","bblid")
df<-merge(subjects,ageSex,by="scanid")
df<-merge(df,motiondf,by='bblid')

### community solutions guaged in this iteration
community_vec<-seq(2,30)

# big load - output of fc_to_csv.m (all coupling/FC data, pre-organized)
fc<-vroom('/cbica/projects/pinesParcels/results/aggregated_data/fc/master_fcfeats_rounded.csv')
# First row gotta go
fc<-fc[-c(1)]
# isolate shams
shams<-fc[694:695,]
# Merge with non-fMR data into master data frame
masterdf<-merge(fc,df,by='bblid')

# add EF
subjbehav<-read.csv("~/Downloads/n9498_cnb_factor_scores_fr_20170202.csv")
ef<-data.frame(subjbehav$NAR_F1_Exec_Comp_Cog_Accuracy,subjbehav$bblid)
colnames(ef)<-c('EF','bblid')
# merge in
masteref<-merge(masterdf,ef,by='bblid')
# and include EF in masterdf - keep more redundant code between sections this way
masterdf<-masteref

### Get in Consensus-reference atlas correspondence
rac<-read.csv('/cbica/projects/pinesParcels/results/aggregated_data/fc/network_yCorrespondence_overscales.csv',stringsAsFactors = F)
scalesvec<-as.numeric(rac[2,])
domnetvec<-as.factor(rac[3,])
netpropvec<-as.numeric(rac[4,])
# 17 network version
rac17<-read.csv('/cbica/projects/pinesParcels/results/aggregated_data/fc/network_y17Correspondence_overscales.csv',stringsAsFactors = F)
scalesvec17<-as.numeric(rac17[2,])
domnetvec17<-as.factor(rac17[3,])
netpropvec17<-as.numeric(rac17[4,])

#### read in transmodality
tm<-read.csv('/cbica/projects/pinesParcels/results/aggregated_data/fc/network_transmodality_overscales.csv',stringsAsFactors = F)
colnames(tm)<-tm[1,]
# aaaand remove it so we got everything in its right place
tm<-tm[-c(1),]
tmvec<-as.numeric(tm)
# use median transmodality value to split relatively bimodal distribution
medtrans<-median(tmvec)
# equivalent vector to be overwritten with binary classification of transmodality
tmclass<-tmvec
for (i in 1:length(tmclass)){
  if (tmvec[i]<= medtrans){
    tmclass[i]='unimodal'
  }else{
    tmclass[i]='transmodal'
  }
}


# parse fields of interest 


# indicators of processing stream
ind='ind'
gro='gro'
bts='bts'

# indicators of fc feature type
bwi='_bw_FC_'
wini='_win_FC_'
nsegi='_seg_scale'
#gsegi='_globseg_scale'

# indices of said indicators
indiv=grep(ind,colnames(masterdf))
#group=grep(gro,colnames(masterdf))
#basists=grep(bts,colnames(masterdf))
bwcol=grep(bwi,colnames(masterdf))
wincols=grep(wini,colnames(masterdf))
nsegcols=grep(nsegi,colnames(masterdf))
#gsegcols=grep(gsegi,colnames(masterdf))

### Using index combinations, get to dataframe of interest
indiv_bwcols_ind<-intersect(bwcol,indiv)
individ_scalebybw_df<-masterdf[,indiv_bwcols_ind]
bwcolnames<-colnames(individ_scalebybw_df)
indiv_nsegcols_ind<-intersect(nsegcols,indiv)
indiv_wincols_ind<-intersect(wincols,indiv)
individ_scalebywin_df<-masterdf[,indiv_wincols_ind]
# to later use wincolname -> bwcolname mapping to extrapolate if if network is unimodal or transmodal along bwcol indices
wincolnames<-colnames(individ_scalebywin_df)

# get average between-network connectivity of each network (average over each network's edges at each scale)



# empty array for each nets average b/w con across subjects
bwAvgCon<-matrix(0,693,464)
# loop over connectivities to-unimodal then to-transmodal
modalloopvar=c('unimodal','transmodal')
for (i in 1:2){
  print(modalloopvar[i])
  # index "the other"
  modalloopvar_other=modalloopvar[modalloopvar!=(modalloopvar[i])]
  # extract which of 1:464 network mappings match the modalitity of this loop
  modalindices=which(tmclass %in% modalloopvar[i])
  # loop over each scale
  for (K in 2:30){
    # Make index of where values from this K should go
    K_start=((K-1)*(K))/2
    K_end=(((K-1)*(K))/2)+K-1
    Kind<-K_start:K_end
    
    # index which values are at this scale
    scaleStr=paste('scale',K,'_',sep='')
    scaleCols_inds=grep(scaleStr,colnames(masterdf))
    scaleK_bw_indivi_cols_inds<-intersect(indiv_bwcols_ind,scaleCols_inds)
    # extract within and between colnames at this scale for within->b/w binarized transmodality mapping
    wincolnames_thisScale_inds<-grep((paste('scale',K,'_',sep='')),wincolnames)
    wincolnames_thisScale=wincolnames[wincolnames_thisScale_inds]
    bwcolnames_thisScale_inds<-grep((paste('scale',K,'_',sep='')),bwcolnames)
    bwcolnames_thisScale=bwcolnames[bwcolnames_thisScale_inds]
    
    # This was to double check that the "scale" grepping was selective enough
    # print(paste(scaleStr,'number of features:',length(bwcolnames_thisScale)))
    # one weird trick to get binarized transmodality class vector for same scale (Doctors hate him!)
    # tm naming aligns with wincon naming
    tmclasses_thisScale<-tmclass[wincolnames_thisScale_inds]
    # extract the network number of each network at this scale in same order as tmclasses_thisScale
    wincolNamesSplit<-strsplit(wincolnames_thisScale,"_net")
    wincolNames_net<-sapply(wincolNamesSplit, "[[" , 2)
    # mini matching vectors with network label at this scale in one col and transmodality binarization in the other
    tmMatchingVecs<-cbind(wincolNames_net,tmclasses_thisScale)
    # remove scale number from strings so we're not picking up on those
    bwcolnames_thisScale_split<-strsplit(bwcolnames_thisScale,"nets")
    bwnetnames_thisScale<-wincolNames_net<-sapply(bwcolnames_thisScale_split, "[[" , 2)
    # add another fucking set of underscores to all of these colnames so 1's dont pick up 10s
    bwnetnames_thisScale_extended<-paste('ind_bw_FC_scale',K,'_nets_',bwnetnames_thisScale,'_',sep='')
    # extra goddamn undercores have to go here and be removed later
    bwcolnames_thisScale_split<-strsplit(bwcolnames_thisScale,"nets")
    # to be matched in all-networks-at-this-scale loop
    # now as we descend into the third circle of for-loop hell, we find the guy from man vs.food being eaten alive by cerberus
    for (N in 1:K){
      # generate index for where values for this network at this scale should reside
      # start from K index
      Nind<-Kind[N]
      # get index for this N in terms of masterdf (collapse | to match multiple patterns)
      Ncolname<-grep(as.character(paste('_',N,'_',sep='')),bwnetnames_thisScale_extended,value=T)
      # need to add "_" before and after each number so I can select for '_N_' and not pick up teens digits with 1, 20s with 3, 15 and 25 with 5, etc.
      # determine if this network is transmodal or unimodal
      NModality<-tmMatchingVecs[,2][[N]]
      NotNModality<-modalloopvar[modalloopvar!=NModality]
      matchvec<-grep(NModality,tmclasses_thisScale)
      # remove self
      matchvec<-matchvec[matchvec!=N]
      # build index of matching modalities to reference masterdf (collapse | to match multiple patterns)
      matchTruncColName<-grep(as.character(paste('_',matchvec,'_',sep='',collapse="|")),Ncolname,value=T)
      # remove first and last characters now that we are specific
      #matchTruncColName<-sub('.$','',matchTruncColName)
      #matchTruncColName<-sub('.','',matchTruncColName)
      # deal with weird thing where empty space was being grepped because of its aspecificity at coarse scales
      if(length(matchTruncColName)==0){
        matchTruncColName[1]='CANTSEEME'
      }
      match_NetN_scaleK_bw_indivi_cols_ind_within_other_ind<-grep(as.character(paste(matchTruncColName,collapse="|")),bwnetnames_thisScale_extended)
      match_NetN_scaleK_bw_indivi_cols_names<-bwcolnames_thisScale[match_NetN_scaleK_bw_indivi_cols_ind_within_other_ind]
      # deep-sea grepping the whole paste and pipe thing is just to deal with character vectors instead of single patterns
      
      # deal with weird thing where empty space was being grepped because of its aspecificity
      if(length(match_NetN_scaleK_bw_indivi_cols_names)==0){
        match_NetN_scaleK_bw_indivi_cols_names[1]='CANTSEEME'
      }
      
      # added a faux '_' to end of column to col names can more selectively match numbers (not picking up on 20 when looking for 2, 2_ and 20_ more distinct)
      match_NetN_scaleK_bw_indivi_cols_ind<-grep(as.character(paste(match_NetN_scaleK_bw_indivi_cols_names,'_',sep='',collapse="|")),paste(colnames(masterdf),'_',sep=''))
      
      
      oppositevec<-grep(NotNModality,tmclasses_thisScale)
      
      # build index of NON-matching modalities to reference masterdf (collapse | to match multiple patterns)
      unmatchTruncColName<-grep(as.character(paste('_',oppositevec,'_',sep='',collapse="|")),Ncolname,value=T)
      # search for string in limited bwcolnames at this scale so as not to invite other scales into this grep party
      # remove first and last characters now that we are specific
      #unmatchTruncColName<-sub('.$','',unmatchTruncColName)
      #unmatchTruncColName<-sub('.','',unmatchTruncColName)
      unmatch_NetN_scaleK_bw_indivi_cols_names<-grep(as.character(paste(unmatchTruncColName,collapse="|")),bwnetnames_thisScale_extended,value=T)
      
      # deep-sea grepping the whole paste and pipe thing is just to deal with character vectors instead of single patterns
      unmatch_NetN_scaleK_bw_indivi_cols_ind_within_other_ind<-grep(as.character(paste(unmatch_NetN_scaleK_bw_indivi_cols_names,collapse="|")),bwnetnames_thisScale_extended)
      unmatch_NetN_scaleK_bw_indivi_cols_names<-bwcolnames_thisScale[unmatch_NetN_scaleK_bw_indivi_cols_ind_within_other_ind]
      unmatch_NetN_scaleK_bw_indivi_cols_ind<-grep(as.character(paste(unmatch_NetN_scaleK_bw_indivi_cols_names,'_',sep='',collapse="|")),paste(colnames(masterdf),'_',sep=''))
      
      
      # doublecheck that they are mutually exclusive (+1 because self-reference gets removed)
      #  if(length(tmclasses_thisScale)!=length(matchvec)+length(oppositevec)+1){
      #     print('You done goofed, internet police are on their way')
      # }
      if(length(tmclasses_thisScale)!=length(match_NetN_scaleK_bw_indivi_cols_ind)+length(unmatch_NetN_scaleK_bw_indivi_cols_ind)+1){
        print('Names dont add up chief')
        paste('match numbas', length(match_NetN_scaleK_bw_indivi_cols_ind), length(match_NetN_scaleK_bw_indivi_cols_names))
        paste('unmatch numbas', length(unmatch_NetN_scaleK_bw_indivi_cols_ind), length(unmatch_NetN_scaleK_bw_indivi_cols_names))
        stopifnot(length(tmclasses_thisScale)==length(match_NetN_scaleK_bw_indivi_cols_ind)+length(unmatch_NetN_scaleK_bw_indivi_cols_ind)+1)
      }
      
      # if it does not match the modality of the grandparent loop, we wish go assay its connections to opposite-modality networks
      # get average bw network connectivty age correlation for this network at this scale
      both=cbind(masterdf[,match_NetN_scaleK_bw_indivi_cols_ind],masterdf[,unmatch_NetN_scaleK_bw_indivi_cols_ind, drop=F])
      avg_bw=rowMeans(both)
      # for bw-based gams later - convert all b/w cons for a net to avg b/w for each subj
      bwAvgCon[,Nind]=avg_bw
    }
  }
  
}


# calculate EF effects
# set covariates formula for iterating over in the loop
lm_xM_covariates="~Age+Sex+Motion"
lm_My_covariates="EF~Sex+Motion+Age+"


# initialize output vectors
AB_Est<-rep(0,length=length(masterdf[,indiv_nsegcols_ind]))
AB_P<-rep(0,length=length(masterdf[,indiv_nsegcols_ind]))


# borrowing colnames from indiv_nsegcols to keep network/scale ordering/mappings
colnames(bwAvgCon)<-gsub("_seg_","_avgBw_",colnames(masterdf[,indiv_nsegcols_ind]))
bwAvgCondf<-data.frame(bwAvgCon)

#add on covariate columns
bwAvgCondf$Age<-masterdf$Age
bwAvgCondf$Sex<-masterdf$Sex
bwAvgCondf$Motion<-masterdf$Motion
bwAvgCondf$EF<-masterdf$EF
# standarized (z-scored) version for mediation interpretation (EF is already normalized)
bwAvgCondfZ<-bwAvgCondf
bwAvgCondfZ$Age<-scale(bwAvgCondf$Age)[,1]
bwAvgCondfZ$Motion<-scale(bwAvgCondf$Motion)[,1]


#for i in 464, -3 because age sex motionand EF columns sit at the end
for (i in 1:(length(bwAvgCondf)-4)){
  # borrowing colnames from indiv_nsegcols to keep network mappings
  x<-colnames(bwAvgCondf[i])
  # to estimate AB path mediation from age to EF (linear)
  # scale for EZ interpretation
  bwAvgCondfZ[,i]<-scale(bwAvgCondfZ[,i])[,1]
  # fit x-M path
  xM_form<-as.formula(paste("",x,"", lm_xM_covariates, sep=""))
  xMpath<-lm(formula=xM_form,data=bwAvgCondfZ)
  # fit M-y path
  My_form<-as.formula(paste(lm_My_covariates, "",x,"",sep=""))
  Mypath<-lm(formula=My_form,data=bwAvgCondfZ)
  # run mediation
  mediationFit<-mediate(xMpath,Mypath,treat="Age",mediator=x)
  AB_Est[i]<-mediationFit$d1
  # save p value in vector as well
  AB_P[i]<-mediationFit$d1.p
}

# fdr Mediation P's
corrected<-p.adjust(AB_P,method='fdr')

# network-level sig vector
NL_sigVec<-logical(464)
NL_sigVec[corrected<0.05]<-TRUE

# bring it all together
bwdf<-data.frame(tmvec,scalesvec,domnetvec,domnetvec17,netpropvec,AB_Est)


#### LINEAR VERSION

#OG coefs. 
AB_Est<-rep(0,464)
for (n in 1:464){
  # first 464 columns are network-level connectivity values. test each.
  x<-colnames(bwAvgCondf[n])
  # to estimate AB path mediation from age to EF (linear)
  # scale for EZ interpretation
  bwAvgCondfZ[,n]<-scale(bwAvgCondfZ[,n])[,1]
  # fit x-M path
  xM_form<-as.formula(paste("",x,"", lm_xM_covariates, sep=""))
  xMpath<-lm(formula=xM_form,data=bwAvgCondfZ)
  # fit M-y path
  My_form<-as.formula(paste(lm_My_covariates, "",x,"",sep=""))
  Mypath<-lm(formula=My_form,data=bwAvgCondfZ)
  # run mediation
  mediationFit<-mediate(xMpath,Mypath,treat="Age",mediator=x)
  AB_Est[i]<-mediationFit$d1
}
# create network-level dataframe from subject-level results: tmvec is just a vector of transmodality values for each network
NL_bwdf<-data.frame(tmvec,avg_bw_deltaR2)
# fit full model
OG_MedEff_by_transmodality_model<-lm(avg_bw_deltaR2~tmvec,data=NL_bwdf)
# Extract Linear coef.
OG_MedEff_by_transmodality_model_LIN<-summary(OG_MedEff_by_transmodality_model)$coefficients['tmvec',]
OG_MedEff_by_transmodality_model_LIN_beta<-OG_MedEff_by_transmodality_model_LIN['Estimate']

#### subject-level resample: outer loop
set.seed(iter)
# set number of bootstraps
b<-100
# initialize likelihood ratio test output vector: one value for each bootstrap
AB_testStatLIN<-rep(0,b)
# now bootstrap "b" times
for (strap in 1:b){
  print(strap)
  # initialize network-level output vector for each bootstrap
  AB_Est<-rep(0,464)
  # now bootstrapping 693 subjects rather than 464 networks
  sampIndices<-sample(1:693,replace=T)
  # bwAvgCondf is a leaner version of the master dataframe with all variables needed here.
  resampDF<-bwAvgCondf[sampIndices,]
  #### fit model to all 464 networks: inner loop
  for (n in 1:464){
    x<-colnames(bwAvgCondf[n])
    # to estimate AB path mediation from age to EF (linear)
    # scale for EZ interpretation
    bwAvgCondfZ[,n]<-scale(bwAvgCondfZ[,n])[,1]
    # fit x-M path
    xM_form<-as.formula(paste("",x,"", lm_xM_covariates, sep=""))
    xMpath<-lm(formula=xM_form,data=bwAvgCondfZ)
    # fit M-y path
    My_form<-as.formula(paste(lm_My_covariates, "",x,"",sep=""))
    Mypath<-lm(formula=My_form,data=bwAvgCondfZ)
    # run mediation
    mediationFit<-mediate(xMpath,Mypath,treat="Age",mediator=x)
    AB_Est[i]<-mediationFit$d1
  }
  #### end of inner loop 
  # create network-level dataframe from subject-level results: tmvec is just a vector of transmodality values for each network
  NL_bwdf<-data.frame(tmvec,AB_Est)
  # Now, test relationship between age effect and transmodality for this bootstrap with likelihood ratio test between nested models
  # fit full model
  Med_Eff_by_transmodality_model<-lm(AB_Est~tmvec,data=NL_bwdf)
  # save linear fit of transmodality
  tmFitLIN<-summary(Med_Eff_by_transmodality_model)$coefficients['tmvec',]
  AB_testStatLIN[strap]<-tmFitLIN['Estimate']
}
#### end of outer loop

# for linear - significance
CI_LIN=quantile(AB_testStatLIN,c(0.025,0.975)) 

# discrete p calculation (https://www.bmj.com/content/343/bmj.d2304 as source)
SE=(CI_LIN[2]-CI_LIN[1])/(2*1.96)
z=OG_MedEff_by_transmodality_model_LIN_beta/SE
z=abs(z)
pLIN<-exp((-0.717*z)-(0.416*(z^2)))

savedBOOTinfo<-data.frame(AB_testStatLIN)
name=paste('~/Med_NetLevel_bootInfo',iter,'.rds',sep='')
saveRDS(savedBOOTinfo,name)
