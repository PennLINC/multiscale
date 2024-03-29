# iteration number, probz will split this into 10 jobs. set seed as iteration number for different bootstraps

#libraries
library(mediation)
library(ggplot2)
library(reshape2)
library(dplyr)
library(vroom)
library(data.table)
library(mgcv)
library(ppcor)


# functions for age effect calculations

# difference in R2 for EF
EFDeltaR2EstVec<-function(x){
  
  # relevant df
  scaledf<-data.frame(cbind(as.numeric(masteref$F1_Exec_Comp_Cog_Accuracy),as.numeric(masteref$Age),as.numeric(masteref$Sex),masteref$Motion,x))
  colnames(scaledf)<-c('EF','Age','Sex','Motion','varofint')
  
  # no-EF model (b.w. ~ sex + motion)
  noEFGam<-gam(varofint~Sex+Motion+s(Age,k=3),data=scaledf)
  noEFSum<-summary(noEFGam)
  # EF-included model for measuring difference
  EFGam<-gam(varofint~EF+Sex+Motion+s(Age,k=3),data=scaledf)
  EFSum<-summary(EFGam)
  
  dif<-EFSum$r.sq-noEFSum$r.sq
  
  # partial spearmans to extract EF relation (for direction)
  pspear=pcor(scaledf,method='spearman')$estimate
  corest<-pspear[5]
  if(corest<0){
    dif=dif*-1
  }
  
  return(dif)
  
}

# same thing but returning chisq test sig. output for FDR correction instead of hard difference
EFDeltaPEstVec<-function(x){
  
  # relevant df
  scaledf<-data.frame(cbind(as.numeric(masteref$F1_Exec_Comp_Cog_Accuracy),as.numeric(masteref$Age),as.numeric(masteref$Sex),masteref$Motion,x))
  colnames(scaledf)<-c('EF','Age','Sex','Motion','varofint')
  
  # no-EF model (segreg ~ sex + motion)
  noEFGam<-gam(varofint~Sex+Motion+s(Age,k=3),data=scaledf)
  # EF-included model for measuring difference
  EFGam<-gam(varofint~EF+Sex+Motion+s(Age,k=3),data=scaledf)
  
  # test of dif with anova.gam
  anovaRes<-anova.gam(noEFGam,EFGam,test='Chisq')
  anovaP<-anovaRes$`Pr(>Chi)`
  anovaP2<-unlist(anovaP)
  return(anovaP2[2])
  
}

# bootstrap version: resampled df instead of master df
EFDeltaR2EstVec_RS<-function(x){
  
  # relevant df
  scaledf<-data.frame(cbind(as.numeric(resampDF$F1_Exec_Comp_Cog_Accuracy),as.numeric(resampDF$Age),as.numeric(resampDF$Sex),resampDF$Motion,x))
  colnames(scaledf)<-c('EF','Age','Sex','Motion','varofint')
  
  
  # no-EF model (b.w. ~ sex + motion)
  noEFGam<-gam(varofint~Sex+Motion+s(Age,k=3),data=scaledf)
  noEFSum<-summary(noEFGam)
  # EF-included model for measuring difference
  EFGam<-gam(varofint~EF+Sex+Motion+s(Age,k=3),data=scaledf)
  EFSum<-summary(EFGam)
  
  dif<-EFSum$r.sq-noEFSum$r.sq
  
  # partial spearmans to extract age relation (for direction)
  pspear=pcor(scaledf,method='spearman')$estimate
  corest<-pspear[5]
  if(corest<0){
    dif=dif*-1
  }
  
  return(dif)
  
}

# difference in R2 for Social Cog
EFDeltaR2EstVec_Soc<-function(x){
  
  # relevant df
  scaledf<-data.frame(cbind(as.numeric(masteref$F2_Social_Cog_Accuracy),as.numeric(masteref$Age),as.numeric(masteref$Sex),masteref$Motion,x))
  colnames(scaledf)<-c('EF','Age','Sex','Motion','varofint')
  
  # no-EF model (b.w. ~ sex + motion)
  noEFGam<-gam(varofint~Sex+Motion+s(Age,k=3),data=scaledf)
  noEFSum<-summary(noEFGam)
  # EF-included model for measuring difference
  EFGam<-gam(varofint~EF+Sex+Motion+s(Age,k=3),data=scaledf)
  EFSum<-summary(EFGam)
  
  dif<-EFSum$r.sq-noEFSum$r.sq
  
  # partial spearmans to extract EF relation (for direction)
  pspear=pcor(scaledf,method='spearman')$estimate
  corest<-pspear[5]
  if(corest<0){
    dif=dif*-1
  }
  
  return(dif)
  
}

# same thing but returning chisq test sig. output for FDR correction instead of hard difference
EFDeltaPEstVec_Soc<-function(x){
  
  # relevant df
  scaledf<-data.frame(cbind(as.numeric(masteref$F2_Social_Cog_Accuracy),as.numeric(masteref$Age),as.numeric(masteref$Sex),masteref$Motion,x))
  colnames(scaledf)<-c('EF','Age','Sex','Motion','varofint')
  
  # no-EF model (segreg ~ sex + motion)
  noEFGam<-gam(varofint~Sex+Motion+s(Age,k=3),data=scaledf)
  # EF-included model for measuring difference
  EFGam<-gam(varofint~EF+Sex+Motion+s(Age,k=3),data=scaledf)
  
  # test of dif with anova.gam
  anovaRes<-anova.gam(noEFGam,EFGam,test='Chisq')
  anovaP<-anovaRes$`Pr(>Chi)`
  anovaP2<-unlist(anovaP)
  return(anovaP2[2])
  
}

# bootstrap version: resampled df instead of master df
EFDeltaR2EstVec_RS_Soc<-function(x){
  
  # relevant df
  scaledf<-data.frame(cbind(as.numeric(resampDF$F2_Social_Cog_Accuracy),as.numeric(resampDF$Age),as.numeric(resampDF$Sex),resampDF$Motion,x))
  colnames(scaledf)<-c('EF','Age','Sex','Motion','varofint')
  
  
  # no-EF model (b.w. ~ sex + motion)
  noEFGam<-gam(varofint~Sex+Motion+s(Age,k=3),data=scaledf)
  noEFSum<-summary(noEFGam)
  # EF-included model for measuring difference
  EFGam<-gam(varofint~EF+Sex+Motion+s(Age,k=3),data=scaledf)
  EFSum<-summary(EFGam)
  
  dif<-EFSum$r.sq-noEFSum$r.sq
  
  # partial spearmans to extract age relation (for direction)
  pspear=pcor(scaledf,method='spearman')$estimate
  corest<-pspear[5]
  if(corest<0){
    dif=dif*-1
  }
  
  return(dif)
  
}

### ### ### ### ### ###
### Memory scores, F3
### ### ### ### ### ### 

EFDeltaR2EstVec_Mem<-function(x){
  
  # relevant df
  scaledf<-data.frame(cbind(as.numeric(masteref$F3_Memory_Accuracy),as.numeric(masteref$Age),as.numeric(masteref$Sex),masteref$Motion,x))
  colnames(scaledf)<-c('EF','Age','Sex','Motion','varofint')
  
  # no-EF model (b.w. ~ sex + motion)
  noEFGam<-gam(varofint~Sex+Motion+s(Age,k=3),data=scaledf)
  noEFSum<-summary(noEFGam)
  # EF-included model for measuring difference
  EFGam<-gam(varofint~EF+Sex+Motion+s(Age,k=3),data=scaledf)
  EFSum<-summary(EFGam)
  
  dif<-EFSum$r.sq-noEFSum$r.sq
  
  # partial spearmans to extract EF relation (for direction)
  pspear=pcor(scaledf,method='spearman')$estimate
  corest<-pspear[5]
  if(corest<0){
    dif=dif*-1
  }
  
  return(dif)
  
}

# same thing but returning chisq test sig. output for FDR correction instead of hard difference
EFDeltaPEstVec_Mem<-function(x){
  
  # relevant df
  scaledf<-data.frame(cbind(as.numeric(masteref$F3_Memory_Accuracy),as.numeric(masteref$Age),as.numeric(masteref$Sex),masteref$Motion,x))
  colnames(scaledf)<-c('EF','Age','Sex','Motion','varofint')
  
  # no-EF model (segreg ~ sex + motion)
  noEFGam<-gam(varofint~Sex+Motion+s(Age,k=3),data=scaledf)
  # EF-included model for measuring difference
  EFGam<-gam(varofint~EF+Sex+Motion+s(Age,k=3),data=scaledf)
  
  # test of dif with anova.gam
  anovaRes<-anova.gam(noEFGam,EFGam,test='Chisq')
  anovaP<-anovaRes$`Pr(>Chi)`
  anovaP2<-unlist(anovaP)
  return(anovaP2[2])
  
}

# bootstrap version: resampled df instead of master df
EFDeltaR2EstVec_RS_Mem<-function(x){
  
  # relevant df
  scaledf<-data.frame(cbind(as.numeric(resampDF$F3_Memory_Accuracy),as.numeric(resampDF$Age),as.numeric(resampDF$Sex),resampDF$Motion,x))
  colnames(scaledf)<-c('EF','Age','Sex','Motion','varofint')
  
  
  # no-EF model (b.w. ~ sex + motion)
  noEFGam<-gam(varofint~Sex+Motion+s(Age,k=3),data=scaledf)
  noEFSum<-summary(noEFGam)
  # EF-included model for measuring difference
  EFGam<-gam(varofint~EF+Sex+Motion+s(Age,k=3),data=scaledf)
  EFSum<-summary(EFGam)
  
  dif<-EFSum$r.sq-noEFSum$r.sq
  
  # partial spearmans to extract age relation (for direction)
  pspear=pcor(scaledf,method='spearman')$estimate
  corest<-pspear[5]
  if(corest<0){
    dif=dif*-1
  }
  
  return(dif)
  
}


# load 'erry thang
### load in demograhics
demo<-read.csv('/home/pinesa/ms_data/pnc_demo.csv')
ageSex<-data.frame(demo$ageAtScan1,as.factor(demo$sex),demo$scanid,demo$bblid)
subjects<-read.csv('/home/pinesa/ms_data/participants.txt',header = F)

### Collapse Motion metric 
# read in
Rest_Motion_Data <- read.csv("/home/pinesa/ms_data/n1601_RestQAData_20170714.csv")
NBack_Motion_Data <- read.csv("/home/pinesa/ms_data/n1601_NBACKQAData_20181001.csv")
Idemo_Motion_Data <- read.csv("/home/pinesa/ms_data/n1601_idemo_FinalQA_092817.csv")
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
fc<-vroom('/home/pinesa/ms_data/master_fcfeats_task_rounded.csv')
# First row gotta go
fc<-fc[-c(1)]
# isolate shams
shams<-fc[694:695,]
# Merge with non-fMR data into master data frame
masterdf<-merge(fc,df,by='bblid')

# and executive function
# get EF in here
subjbehav<-read.csv("/home/pinesa/ms_data/n9498_cnb_factor_scores_fr_20170202.csv")
ef<-data.frame(subjbehav$NAR_F1_Exec_Comp_Cog_Accuracy,subjbehav$bblid)
Soc<-data.frame(subjbehav$NAR_F2_Social_Cog_Accuracy,subjbehav$bblid)
Mem<-data.frame(subjbehav$NAR_F3_Memory_Accuracy,subjbehav$bblid)
colnames(ef)<-c('F1_Exec_Comp_Cog_Accuracy','bblid')
colnames(Soc)<-c('F2_Social_Cog_Accuracy','bblid')
colnames(Mem)<-c('F3_Memory_Accuracy','bblid')
# merge in
masteref<-merge(masterdf,ef,by='bblid')
masteref<-merge(masteref,Soc,by='bblid')
masteref<-merge(masteref,Mem,by='bblid')

### Get in Consensus-reference atlas correspondence
rac<-read.csv('/home/pinesa/ms_data/network_yCorrespondence_overscales.csv',stringsAsFactors = F)
scalesvec<-as.numeric(rac[2,])
domnetvec<-as.factor(rac[3,])
netpropvec<-as.numeric(rac[4,])
# 17 network version
rac17<-read.csv('/home/pinesa/ms_data/network_y17Correspondence_overscales.csv',stringsAsFactors = F)
scalesvec17<-as.numeric(rac17[2,])
domnetvec17<-as.factor(rac17[3,])
netpropvec17<-as.numeric(rac17[4,])

#### read in transmodality
tm<-read.csv('/home/pinesa/ms_data/network_transmodality_overscales.csv',stringsAsFactors = F)
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

# and make into df
bwAvgCondf<-data.frame(bwAvgCon)
#add on covariate columns
bwAvgCondf$Age<-masterdf$Age
bwAvgCondf$Sex<-masterdf$Sex
bwAvgCondf$Motion<-masterdf$Motion
bwAvgCondf$F1_Exec_Comp_Cog_Accuracy<-masteref$F1_Exec_Comp_Cog_Accuracy
bwAvgCondf$F2_Social_Cog_Accuracy<-masteref$F2_Social_Cog_Accuracy
bwAvgCondf$F3_Memory_Accuracy<-masteref$F3_Memory_Accuracy
#### LINEAR VERSION

#OG coefs. 
avg_bw_deltaR2<-rep(0,464)
avg_bw_deltaP<-rep(0,464)
for (n in 1:464){
  # first 464 columns are network-level connectivity values. test each.
  # this is a function that return full vs. reduced model comparisons (Age included vs. age excluded, controls for sex + motion).
  avg_bw_deltaR2[n]<-EFDeltaR2EstVec(bwAvgCondf[n])
}
# create network-level dataframe from subject-level results: tmvec is just a vector of transmodality values for each network
NL_bwdf<-data.frame(tmvec,avg_bw_deltaR2)
# fit full model
OG_EFEff_by_transmodality_model<-lm(avg_bw_deltaR2~tmvec,data=NL_bwdf)
# Extract Linear coef.
OG_EFEff_by_transmodality_model_LIN<-summary(OG_EFEff_by_transmodality_model)$coefficients['tmvec',]
OG_EFEff_by_transmodality_model_LIN_beta<-OG_EFEff_by_transmodality_model_LIN['Estimate']

#### subject-level resample: outer loop
set.seed(1)
# set number of bootstraps
b<-1000
# initialize likelihood ratio test output vector: one value for each bootstrap
lm_testStatLIN<-rep(0,b)
lm_testPvecLIN<-rep(0,b)
lm_testStatQUADR<-rep(0,b)
SMA_testStatQuadr<-rep(0,b)
SMA_testStatLin<-rep(0,b)
SM_testStatQuadr<-rep(0,b)
SM_testStatLin<-rep(0,b)
DMB_testStatQuadr<-rep(0,b)
DMB_testStatLin<-rep(0,b)
DM_testStatQuadr<-rep(0,b)
DM_testStatLin<-rep(0,b)
# Social
lm_testStatLIN_Soc<-rep(0,b)
lm_testStatQUADR_Soc<-rep(0,b)
# Memory
lm_testStatLIN_Mem<-rep(0,b)
lm_testStatQUADR_Mem<-rep(0,b)
# now bootstrap "b" times
for (x in 1:b){
  # initialize network-level output vector for each bootstrap
  avg_bw_deltaR2<-rep(0,464)
  avg_bw_deltaP<-rep(0,464)
  avg_bw_deltaR2_Soc<-rep(0,464)
  avg_bw_deltaR2_Mem<-rep(0,464)
  # now bootstrapping 693 subjects rather than 464 networks
  sampIndices<-sample(1:693,replace=T)
  # bwAvgCondf is a leaner version of the master dataframe with all variables needed here.
  resampDF<-bwAvgCondf[sampIndices,]
  #### fit model to all 464 networks: inner loop
  for (n in 1:464){
    # first 464 columns are network-level connectivity values. test each.
    # this is a function that return full vs. reduced model comparisons (Age included vs. age excluded, controls for sex + motion).
    avg_bw_deltaR2[n]<-EFDeltaR2EstVec_RS(resampDF[n])
    avg_bw_deltaR2_Soc[n]<-EFDeltaR2EstVec_RS_Soc(resampDF[n])
    avg_bw_deltaR2_Mem[n]<-EFDeltaR2EstVec_RS_Mem(resampDF[n])
  }
  #### end of inner loop 
  # create network-level dataframe from subject-level results: tmvec is just a vector of transmodality values for each network
  NL_bwdf<-data.frame(tmvec,avg_bw_deltaR2,avg_bw_deltaR2_Soc,avg_bw_deltaR2_Mem)
  # Now, test relationship between age effect and transmodality for this bootstrap with likelihood ratio test between nested models
  # fit full model
  EFEff_by_transmodality_model<-lm(avg_bw_deltaR2~poly(tmvec,2),data=NL_bwdf)
  # save fits of transmodality
  lm_testStatLIN[x]<-EFEff_by_transmodality_model$coefficients['poly(tmvec, 2)1']
  lm_testStatQUADR[x]<-EFEff_by_transmodality_model$coefficients['poly(tmvec, 2)2']
  # and fit SomA and DmB
  bwdf<-data.frame(tmvec,scalesvec,domnetvec,domnetvec17,netpropvec,avg_bw_deltaR2,avg_bw_deltaP)
  SMA_lm<-lm(avg_bw_deltaR2~poly(scalesvec,2),data=bwdf[bwdf$domnetvec17=='Somatomotor A',])
  SM_lm<-lm(avg_bw_deltaR2~poly(scalesvec,2),data=bwdf[bwdf$domnetvec=='Motor',])
  DMB_lm<-lm(avg_bw_deltaR2~poly(scalesvec,2),data=bwdf[bwdf$domnetvec17=='DM_B',])
  DM_lm<-lm(avg_bw_deltaR2~poly(scalesvec,2),data=bwdf[bwdf$domnetvec=='DM',])
  SMA_testStatQuadr[x]<-SMA_lm$coefficients['poly(scalesvec, 2)2']
  SMA_testStatLin[x]<-SMA_lm$coefficients['poly(scalesvec, 2)1']
  SM_testStatQuadr[x]<-SM_lm$coefficients['poly(scalesvec, 2)2']
  SM_testStatLin[x]<-SM_lm$coefficients['poly(scalesvec, 2)1']
  DMB_testStatQuadr[x]<-DMB_lm$coefficients['poly(scalesvec, 2)2']
  DMB_testStatLin[x]<-DMB_lm$coefficients['poly(scalesvec, 2)1']
  DM_testStatQuadr[x]<-DM_lm$coefficients['poly(scalesvec, 2)2']
  DM_testStatLin[x]<-DM_lm$coefficients['poly(scalesvec, 2)1']
  
  # fit full models
  EFEff_by_transmodality_model_Soc<-lm(avg_bw_deltaR2_Soc~poly(tmvec,2),data=NL_bwdf)
  EFEff_by_transmodality_model_Mem<-lm(avg_bw_deltaR2_Mem~poly(tmvec,2),data=NL_bwdf)
  # save fits of transmodality
  lm_testStatLIN_Soc[x]<-EFEff_by_transmodality_model_Soc$coefficients['poly(tmvec, 2)1']
  lm_testStatQUADR_Soc[x]<-EFEff_by_transmodality_model_Soc$coefficients['poly(tmvec, 2)2']
  lm_testStatLIN_Mem[x]<-EFEff_by_transmodality_model_Mem$coefficients['poly(tmvec, 2)1']
  lm_testStatQUADR_Mem[x]<-EFEff_by_transmodality_model_Mem$coefficients['poly(tmvec, 2)2']  
}
#### end of outer loop

savedBOOTinfo<-data.frame(lm_testStatLIN,lm_testPvecLIN,lm_testStatQUADR,SMA_testStatLin,SMA_testStatQuadr,SM_testStatLin,SM_testStatQuadr,DMB_testStatLin,DMB_testStatQuadr,DM_testStatLin,DM_testStatQuadr,lm_testStatLIN_Soc,lm_testStatQUADR_Soc,lm_testStatLIN_Mem,lm_testStatQUADR_Mem)
saveRDS(savedBOOTinfo,'~/EF_NetLevel_task_bootInfo.rds')
  