#libraries
library(mediation)
library(ggplot2)
library(reshape2)
library(dplyr)
library(vroom)
library(data.table)
library(mgcv)
library(ppcor)

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
fc<-vroom('/home/pinesa/ms_data/master_fcfeats_rounded.csv')
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

# Add in pairwise distance between Networks, motion-FC relation
BwAgeCorTMDifDf<-data.frame(tmdifvec,ageDR2vec,as.numeric(distance_array[,2]),motionEfvec,scalevec,Net1Vec,Net2Vec,Net1Vec17,Net2Vec17,fdrAgeDR2,ageDR2vec,domnetSig1,domnetSig2,domnetSigAge1,domnetSigAge2,net1tmvec,net2tmvec)

colnames(BwAgeCorTMDifDf)[3]<-'EucDist'

# Artificial 0s exist where 2 Networks do not exist on the same hemisphere, mask em out
BwAgeCorDistance_nonZero<-BwAgeCorTMDifDf[BwAgeCorTMDifDf$EucDist!=0,]

Euc<-ggplot(data=BwAgeCorDistance_nonZero,aes(x=EucDist,y=ageDR2vec)) + geom_point(alpha=.07,size=3) + xlab('Euclidean Distance') + ylab(expression(paste('Age Effect (',Delta,R^2[adj],')')))+geom_smooth(method='lm')+theme_classic(base_size=40)

Mot<-ggplot(data=BwAgeCorDistance_nonZero,aes(x=EucDist,y=motionEfvec)) + geom_point(alpha=.07,size=3) + xlab('Euclidean Distance') + ylab('Motion Effect')+geom_smooth(method='lm')+theme_classic(base_size=40)

TMd<-ggplot(data=BwAgeCorDistance_nonZero,aes(x=tmdifvec,y=ageDR2vec)) + geom_point(alpha=.07,size=3) + xlab('Transmodality difference') + ylab(expression(paste('Age Effect (',Delta,R^2[adj],')')))+geom_smooth(method='lm')+theme_classic(base_size=40)

TMd_euc<-ggplot(data=BwAgeCorDistance_nonZero,aes(x=EucDist,y=tmdifvec)) + geom_point(alpha=.07,size=3) + xlab('Euclidean Distance') + ylab('Transmodality difference')+geom_smooth(method='lm')+theme_classic(base_size=40)

fullmodel<-lm(ageDR2vec~EucDist+tmdifvec,data=BwAgeCorDistance_nonZero)



#### LINEAR VERSION

#OG coefs. 
EL_bwdf<-data.frame(tmdifvec,ageDR2vec)
# fit full model
OG_AgeEff_by_transmodalityDif_model<-lm(ageDR2vec~tmdifvec,data=EL_bwdf)
# Extract Linear coef.
OG_AgeEff_by_transmodalityDif_model_LIN<-summary(OG_AgeEff_by_transmodalityDif_model)$coefficients['tmdifvec',]
OG_AgeEff_by_transmodalityDif_model_LIN_beta<-OG_AgeEff_by_transmodalityDif_model_LIN['Estimate']

#### subject-level resample: outer loop
set.seed(1)
# set number of bootstraps
b<-1000
# initialize likelihood ratio test output vector: one value for each bootstrap
lm_testStatLIN<-rep(0,b)
lm_testPvecLIN<-rep(0,b)
# added bootstrapping for euclidean distance - age effect relation for comparison
EucAgeSpearman<-rep(0,b)
TmDifAgeSpearman<-rep(0,b)
# now bootstrap "b" times
for (x in 1:b){
  # initialize network-level output vector for each bootstrap
  bw_deltaR2<-rep(0,length(colnames(individ_scalebybw_df)))
  # now bootstrapping 693 subjects rather than 464 networks
  sampIndices<-sample(1:693,replace=T)
  resampDF<-masterdf[sampIndices,]
  
  #### fit model to all network edges: inner loop
  for (n in 1:length(colnames(individ_scalebybw_df))){
    # extract column name. Will parse column name to determine nature of #connection
    curcolname<-colnames(individ_scalebybw_df)[n]
    # get position in master df of this column (need to use \b for exact matches #only)
    curcolnameexact<-paste('\\b',curcolname,'\\b',sep='')
    colindex<-grep(curcolnameexact,colnames(masterdf))
    # delta r2 for age
    bw_deltaR2[n]<-DeltaR2EstVec_RS(resampDF[,colindex])
  }
  #### end of inner loop 
  # create network-level dataframe from subject-level results: tmvec is just a vector of transmodality values for each network
  EL_bwdf<-data.frame(tmdifvec,bw_deltaR2)
  # Now, test relationship between age effect and transmodality for this bootstrap with likelihood ratio test between nested models
  # fit full model
  AgeEff_by_transmodalityDif_model<-lm(bw_deltaR2~tmdifvec,data=EL_bwdf)
  # save linear fit of transmodality
  tmDFitLIN<-summary(AgeEff_by_transmodalityDif_model)$coefficients['tmdifvec',]
  lm_testStatLIN[x]<-tmDFitLIN['Estimate']
  lm_testPvecLIN[x]<-tmDFitLIN['Pr(>|t|)']
  
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
}
#### end of outer loop

# for linear - significance
CI_LIN=quantile(lm_testStatLIN,c(0.025,0.975)) 

# discrete p calculation (https://www.bmj.com/content/343/bmj.d2304 as source)
SE=(CI_LIN[2]-CI_LIN[1])/(2*1.96)
z=OG_AgeEff_by_transmodalityDif_model_LIN_beta/SE
z=abs(z)
pLIN<-exp((-0.717*z)-(0.416*(z^2)))

savedBOOTinfo<-data.frame(lm_testStatLIN,lm_testPvecLIN,TmDifAgeSpearman,EucAgeSpearman)
saveRDS(savedBOOTinfo,'~/Age_EdgeLevel_bootInfo.rds')
