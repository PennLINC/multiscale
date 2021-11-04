iter=commandArgs(trailingOnly=TRUE)
#libraries
library(mediation)
library(ggplot2)
library(reshape2)
library(dplyr)
library(vroom)
library(data.table)
library(mgcv)
library(ppcor)


# functions needed
# functions for delta r ^ 2
# difference in R2
DeltaR2EstVec<-function(x){
  
  # relevant df
  scaledf<-data.frame(cbind(as.numeric(masterdf$Age),as.numeric(masterdf$Sex),masterdf$Motion,x))
  colnames(scaledf)<-c('Age','Sex','Motion','varofint')
  
  # no-age model (segreg ~ sex + motion)
  noAgeGam<-gam(varofint~Sex+Motion,data=scaledf)
  noAgeSum<-summary(noAgeGam)
  # age-included model for measuring difference
  AgeGam<-gam(varofint~Sex+Motion+s(Age,k=3),data=scaledf)
  AgeSum<-summary(AgeGam)
  
  dif<-AgeSum$r.sq-noAgeSum$r.sq
  
  # partial spearmans to extract age relation (for direction)
  pspear=pcor(scaledf,method='spearman')$estimate
  corest<-pspear[4]
  if(corest<0){
    dif=dif*-1
  }
  
  return(dif)
  
}

# same thing but returning chisq test sig. output for FDR correction instead of hard difference
DeltaPEstVec<-function(x){
  
  # relevant df
  scaledf<-data.frame(cbind(as.numeric(masterdf$Age),as.numeric(masterdf$Sex),masterdf$Motion,x))
  colnames(scaledf)<-c('Age','Sex','Motion','varofint')
  
  # no-age model (segreg ~ sex + motion)
  noAgeGam<-gam(varofint~Sex+Motion,data=scaledf)
  # age-included model for measuring difference
  AgeGam<-gam(varofint~Sex+Motion+s(Age,k=3),data=scaledf)
  
  # test of dif with anova.gam
  anovaRes<-anova.gam(noAgeGam,AgeGam,test='Chisq')
  anovaP<-anovaRes$`Pr(>Chi)`
  anovaP2<-unlist(anovaP)
  return(anovaP2[2])
  
}


# bootstrap version: resampled df instead of master df
DeltaR2EstVec_RS<-function(x){
  
  # relevant df
  scaledf<-data.frame(cbind(as.numeric(resampDF$Age),as.numeric(resampDF$Sex),resampDF$Motion,x))
  colnames(scaledf)<-c('Age','Sex','Motion','varofint')
  
  # no-age model (segreg ~ sex + motion)
  noAgeGam<-gam(varofint~Sex+Motion,data=scaledf)
  noAgeSum<-summary(noAgeGam)
  # age-included model for measuring difference
  AgeGam<-gam(varofint~Sex+Motion+s(Age,k=3),data=scaledf)
  AgeSum<-summary(AgeGam)
  
  dif<-AgeSum$r.sq-noAgeSum$r.sq
  
  # partial spearmans to extract age relation (for direction)
  pspear=pcor(scaledf,method='spearman')$estimate
  corest<-pspear[4]
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

# get transmodality differences
tmdifvec=rep(0,length(colnames(individ_scalebybw_df)))
# for recording net1 and net2 tm
net1tmvec=rep(0,length(colnames(individ_scalebybw_df)))
net2tmvec=rep(0,length(colnames(individ_scalebybw_df)))
ageDR2vec=rep(0,length(colnames(individ_scalebybw_df)))
# make a scale vector to match transmodality difference values
# this is to look at how finer scales confer networks that are less different
scalevec=rep(0,length(colnames(individ_scalebybw_df)))
for (i in 1:length(colnames(individ_scalebybw_df))){
  # extract column name. Will parse column name to determine nature of #connection
  curcolname<-colnames(individ_scalebybw_df)[i]
  splitname<-unlist(strsplit(curcolname,'_'))
  scalefield=splitname[4]
  net1field=splitname[5]
  net2field=splitname[7]
  # doctor up scale and net1field so they are exclusively the value of #interest
  scale=as.numeric(unlist(strsplit(scalefield,'e'))[2])
  net1=unlist(strsplit(net1field,'s'))[2]
  net2=net2field
  # helping phriendly index
  K_start=((scale-1)*(scale))/2
  K_end=(((scale-1)*(scale))/2)+scale-1
  Kind<-K_start:K_end
  # get TM values of both nets at this scale
  tm1=tmvec[Kind[as.numeric(net1)]]
  tm2=tmvec[Kind[as.numeric(net2)]]
  net1tmvec[i]<-tm1
  net2tmvec[i]<-tm2
  # absolute value as directionality is meaningless here
  tmdif=abs(tm1-tm2)
  # get position in master df of this column (need to use \b for exact matches #only)
  # added first b 11-9, works if remove
  curcolnameexact<-paste('\\b',curcolname,'\\b',sep='')
  colindex<-grep(curcolnameexact,colnames(masterdf))
  # save to respective vectors
  tmdifvec[i]<-tmdif
  # and just for OG effect calculation
  ageDR2vec[i]<-DeltaR2EstVec(masterdf[,colindex])
}

# work in euclidean distances
######### Look at between-distance relations

## grab matlab-generated euclidean distance vector, match to age effect vector
distance_array=array(dim=c(length(colnames(individ_scalebybw_df)),2))

# make a between over scales vector to keep track of where each between feature sits in the whole multiscale combination
bw_over_scales=NULL
bw_start=0
bw_end=0

for (k in 2:30){
  # index which values are at this scale
  scaleStr=paste('scale',k,'_',sep='')
  scaleCols_inds=grep(scaleStr,colnames(masterdf))
  scaleK_bw_indivi_cols_inds<-intersect(indiv_bwcols_ind,scaleCols_inds)
  
  # load in distance file for this scale
  disfp=paste('/home/pinesa/ms_data/Scale',k,'_Ind_bwColnames_andDist.csv',sep='')
  distancedf<-read.csv(disfp)
  # check to make sure name in file is the same as the corresponding bw col from masterdf
  if (identical((colnames(masterdf)[scaleK_bw_indivi_cols_inds]),distancedf$bwcolscell_1)){
    print('bw column names match')}
  print(k)
  
  # helping phriendly index
  bw_start=bw_end+1
  bw_end=bw_start+((k)*(k-1)/2)-1
  Bwind<-bw_start:bw_end
  
  distance_array[Bwind,1]<-colnames(masterdf)[scaleK_bw_indivi_cols_inds]
  distance_array[Bwind,2]<-distancedf$bwcolscell_2
  
}  

#### LINEAR VERSION

#OG coefs. 
EL_bwdf<-data.frame(tmdifvec,ageDR2vec)
# fit full model
OG_AgeEff_by_transmodalityDif_model<-lm(ageDR2vec~tmdifvec,data=EL_bwdf)
# Extract Linear coef.
OG_AgeEff_by_transmodalityDif_model_LIN<-summary(OG_AgeEff_by_transmodalityDif_model)$coefficients['tmdifvec',]
OG_AgeEff_by_transmodalityDif_model_LIN_beta<-OG_AgeEff_by_transmodalityDif_model_LIN['Estimate']

#### subject-level resample: outer loop
set.seed(iter)
# set number of bootstraps
b<-1000
# initialize likelihood ratio test output vector: one value for each bootstrap
lm_testStatLIN<-rep(0,b)
lm_testPvecLIN<-rep(0,b)
lm_testStatLIN_estAt8<-rep(0,b)
lmN1N2_testStatLIN<-rep(0,b)
# added bootstrapping for euclidean distance - age effect relation for comparison
EucAgeSpearman<-rep(0,b)
TmDifAgeSpearman<-rep(0,b)

# initialize "intercept" (pred. value at 8 y.o.) df
gamPredictMeAt8<-data.frame(1,1)
# * 12 for months
gamPredictMeAt8$Age<-(96)
gamPredictMeAt8$Motion<-mean(masterdf$Motion)
gamPredictMeAt8$Sex<-2

# now bootstrap "b" times
for (x in 1:b){
  # initialize network-level output vector for each bootstrap
  bw_deltaR2<-rep(0,length(colnames(individ_scalebybw_df)))
  # now bootstrapping 693 subjects rather than 464 networks
  sampIndices<-sample(1:693,replace=T)
  resampDF<-masterdf[sampIndices,]
  
  # for the intercept subpanel
  EdgeInterceptVector=rep(0,length(colnames(individ_scalebybw_df)))
  
  #### fit model to all network edges: inner loop
  for (n in 1:length(colnames(individ_scalebybw_df))){
    # extract column name. Will parse column name to determine nature of #connection
    curcolname<-colnames(individ_scalebybw_df)[n]
    # get position in master df of this column (need to use \b for exact matches #only)
    curcolnameexact<-paste('\\b',curcolname,'\\b',sep='')
    colindex<-grep(curcolnameexact,colnames(masterdf))
    # delta r2 for age
    bw_deltaR2[n]<-DeltaR2EstVec_RS(resampDF[,colindex])
    # estimated connectivity at 8 y.o.
    scaledf<-data.frame(cbind(as.numeric(resampDF$Age),as.numeric(resampDF$Sex),resampDF$Motion,resampDF[,colindex]))
    colnames(scaledf)<-c('Age','Sex','Motion','varofint')
    # age-included model for measuring difference
    AgeGam<-gam(varofint~Sex+Motion+s(Age,k=3),data=scaledf)
    # record "intercept" (predicted at 8 y.o.)
    EdgeInterceptVector[n]<-predict.gam(AgeGam,gamPredictMeAt8)
  }
  #### end of inner loop 
  # create network-level dataframe from subject-level results: tmvec is just a vector of transmodality values for each network
  EL_bwdf<-data.frame(tmdifvec,bw_deltaR2)
  # Now, test relationship between age effect and transmodality for this bootstrap with likelihood ratio test between nested models
  # fit full model
  AgeEff_by_transmodalityDif_model<-lm(bw_deltaR2~tmdifvec,data=EL_bwdf)
  # save linear fit of transmodality difference
  lm_testStatLIN[x]<-AgeEff_by_transmodalityDif_model$coefficients['tmdifvec']
  # save linear fit of transmodality difference by est. con. at 8 y.o.
  edgeInt<-data.frame(EdgeInterceptVector,tmdifvec)
  # get lm for stats
  ageEdgeIntLm<-lm(EdgeInterceptVector~tmdifvec,data=edgeInt)
  lm_testStatLIN_estAt8[x]<-ageEdgeIntLm$coefficients['tmdifvec']
  # new section to use bootstrapped Age delta r squared for Age-Euc
  # Artificial 0s exist where 2 Networks do not exist on the same hemisphere, mask em out
  EL_Eucbwdf<-data.frame(as.numeric(distance_array[,2]),bw_deltaR2,tmdifvec)
  colnames(EL_Eucbwdf)[1]<-'EucDist'
  EL_Eucbwdf_nonZeros<-EL_Eucbwdf[EL_Eucbwdf$EucDist!=0,]
  Euc_AgeEfCor<-cor.test(EL_Eucbwdf_nonZeros$EucDist,EL_Eucbwdf_nonZeros$bw_deltaR2,method='spearman')
  EucAgeSpearman[x]<-Euc_AgeEfCor$estimate
  # equiv for transmodality difference (includes scaling)
  Tmdif_AgeEfCor<-cor.test(EL_Eucbwdf_nonZeros$tmdifvec,EL_Eucbwdf_nonZeros$bw_deltaR2,method='spearman')
  TmDifAgeSpearman[x]<-Tmdif_AgeEfCor$estimate
  
  # make a double df for symmetry - net1 and net2tmvec repeated in opposite ordering
  
  BwAgeCorTMDifDf<-data.frame(bw_deltaR2,net1tmvec,net2tmvec)
  # mirror DF
  BwAgeCorTMDifDf2<-BwAgeCorTMDifDf
  BwAgeCorTMDifDf2$net1tmvec<-BwAgeCorTMDifDf$net2tmvec
  BwAgeCorTMDifDf2$net2tmvec<-BwAgeCorTMDifDf$net1tmvec
  
  # "stacked" df
  doubleBwAgeCorTMDifDf<-rbind(BwAgeCorTMDifDf2,BwAgeCorTMDifDf)
  
  # finally, model the simplified network A transmodality network B transmodality interaction
  simpLin<-lm(bw_deltaR2~net2tmvec*net1tmvec,data = doubleBwAgeCorTMDifDf)
  lmN1N2_testStatLIN[x]<-simpLin$coefficients['net2tmvec:net1tmvec']
  
}
#### end of outer loop

# save with seed value in filename
BootInfoName=paste('~/Age_EdgeLevel_Task_bootInfo_',iter,'.rds',sep='')
savedBOOTinfo<-data.frame(lm_testStatLIN,TmDifAgeSpearman,EucAgeSpearman,lm_testStatLIN_estAt8,lmN1N2_testStatLIN)
saveRDS(savedBOOTinfo,BootInfoName)