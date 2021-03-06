Network-level-Mediation
================
Adam
1/19/2021

``` r
# Welcome to the network-level age-Brain-EF mediation markdown. Here, we'll analyze neurodevelopmental/cognitive relations that are observed for individual functional networks, and second-order relationships depicting the distribution of mediation effects across different kinds of networks. 

# More specifically, this markdown contains the analyses neccessary for figures 7A, 7C and 7D. 
```

``` r
#libraries

library(lavaan)
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
```

``` r
# load 'erry thang - next 4 chunks are the same load-in as other .md's



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
```

    ## New names:
    ## * `` -> ...1

    ## Rows: 695
    ## Columns: 16,360
    ## Delimiter: ","
    ## dbl [16360]: ...1, bblid, ind_globseg_scale2, ind_globseg_scale3, ind_globseg_scale4, ind_globse...
    ## 
    ## Use `spec()` to retrieve the guessed column specification
    ## Pass a specification to the `col_types` argument to quiet this message

``` r
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
```

``` r
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
```

``` r
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
```

    ## [1] "unimodal"
    ## [1] "transmodal"

``` r
# for lavaan - set SEM model to be iteratively calculcated for each network at each scale
sem_model = '
  FC ~ a*Age + Sex + Motion
  EF ~ c*Age + Sex + Motion + b*FC
 
  # direct effect
  direct := c
 
  # indirect effect
  indirect := a*b
 
  # total effect
  total := c + (a*b)
'
```

``` r
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

# lavaan
#for i in 464, -3 because age sex motionand EF columns sit at the end
for (i in 1:(length(bwAvgCondf)-4)){
  # borrowing colnames from indiv_nsegcols to keep network mappings
  x<-colnames(bwAvgCondf[i])
  # to estimate AB path mediation from age to EF (linear)
  # scale for EZ interpretation
  bwAvgCondfZ[,i]<-scale(bwAvgCondfZ[,i])[,1]
  sem_model_x = gsub('FC',x,sem_model)
  fit=sem(sem_model_x,bwAvgCondfZ)
  # row 17 is the indirect effect estimate
  AB_Est[i]<-summary(fit)$PE[17,'est']
  # save p value in vector as well
  AB_P[i]<-summary(fit)$PE[17,'pvalue']
}
# fdr Mediation P's
corrected<-p.adjust(AB_P,method='fdr')

# network-level sig vector
NL_sigVec<-logical(464)
NL_sigVec[corrected<0.05]<-TRUE

# bring it all together
bwdf<-data.frame(tmvec,scalesvec,domnetvec,domnetvec17,netpropvec,AB_Est)
```

``` r
# time for a nice, simple one. FIGURE 7A
ggplot(masteref,aes(x=Age/12,y=EF)) +geom_point(size=4,alpha=.6)+geom_smooth(method='lm',color='black',size=4)+theme_classic(base_size=40) + xlab("Age") + ylab("Executive Function")
```

    ## `geom_smooth()` using formula 'y ~ x'

![](Network-level-Mediation_files/figure-markdown_github/unnamed-chunk-8-1.png)

``` r
#### Bootstrap statistics

# create network-level dataframe from subject-level results: tmvec is just a vector of transmodality values for each network
# fit full model
OG_MedEff_by_transmodality_model<-lm(AB_Est~tmvec,data=bwdf)
# Extract Linear coef.
OG_MedEff_by_transmodality_model_LIN<-summary(OG_MedEff_by_transmodality_model)$coefficients['tmvec',]
OG_MedEff_by_transmodality_model_LIN_beta<-OG_MedEff_by_transmodality_model_LIN['Estimate']

# spearman's correlation coefficient for AB path by transmodality relationship
cor.test(bwdf$tmvec,bwdf$AB_Est,method='spearman')
```

    ## Warning in cor.test.default(bwdf$tmvec, bwdf$AB_Est, method = "spearman"):
    ## Cannot compute exact p-value with ties

    ## 
    ##  Spearman's rank correlation rho
    ## 
    ## data:  bwdf$tmvec and bwdf$AB_Est
    ## S = 5290268, p-value < 2.2e-16
    ## alternative hypothesis: true rho is not equal to 0
    ## sample estimates:
    ##       rho 
    ## 0.6822563

``` r
### After bootstrapping on PMACS
r1=readRDS('~/multiscale/Med_NetLevel_bootInfo1.rds')
r2=readRDS('~/multiscale/Med_NetLevel_bootInfo2.rds')
r3=readRDS('~/multiscale/Med_NetLevel_bootInfo3.rds')
r4=readRDS('~/multiscale/Med_NetLevel_bootInfo4.rds')
r5=readRDS('~/multiscale/Med_NetLevel_bootInfo5.rds')
r6=readRDS('~/multiscale/Med_NetLevel_bootInfo6.rds')
r7=readRDS('~/multiscale/Med_NetLevel_bootInfo7.rds')
r8=readRDS('~/multiscale/Med_NetLevel_bootInfo8.rds')
r9=readRDS('~/multiscale/Med_NetLevel_bootInfo9.rds')
r10=readRDS('~/multiscale/Med_NetLevel_bootInfo10.rds')
r11=readRDS('~/multiscale/Med_NetLevel_bootInfo11.rds')
r12=readRDS('~/multiscale/Med_NetLevel_bootInfo12.rds')
r13=readRDS('~/multiscale/Med_NetLevel_bootInfo13.rds')
r14=readRDS('~/multiscale/Med_NetLevel_bootInfo14.rds')
r15=readRDS('~/multiscale/Med_NetLevel_bootInfo15.rds')
r16=readRDS('~/multiscale/Med_NetLevel_bootInfo16.rds')
r17=readRDS('~/multiscale/Med_NetLevel_bootInfo17.rds')
r18=readRDS('~/multiscale/Med_NetLevel_bootInfo18.rds')
r19=readRDS('~/multiscale/Med_NetLevel_bootInfo19.rds')
r20=readRDS('~/multiscale/Med_NetLevel_bootInfo20.rds')

# slap 'em back together (all ran on different seeds)
mergedBootStraps<-rbind(r1$AB_testStatLIN,r2$AB_testStatLIN,r3$AB_testStatLIN,r4$AB_testStatLIN,r5$AB_testStatLIN,r6$AB_testStatLIN,r7$AB_testStatLIN,r8$AB_testStatLIN,r9$AB_testStatLIN,r10$AB_testStatLIN,r11$AB_testStatLIN,r12$AB_testStatLIN,r13$AB_testStatLIN,r14$AB_testStatLIN,r15$AB_testStatLIN,r16$AB_testStatLIN,r17$AB_testStatLIN,r18$AB_testStatLIN,r19$AB_testStatLIN,r20$AB_testStatLIN)

# range of AB~Transmodality
print(range(mergedBootStraps))
```

    ## [1] 0.001875747 0.007452181

``` r
# for linear - significance
CI_LIN=quantile(mergedBootStraps,c(0.025,0.975)) 

# discrete p calculation (https://www.bmj.com/content/343/bmj.d2304 as source)
SE=(CI_LIN[2]-CI_LIN[1])/(2*1.96)
z=OG_MedEff_by_transmodality_model_LIN_beta/SE
z=abs(z)
pLIN<-exp((-0.717*z)-(0.416*(z^2)))

# print out p-value of linear association between AB Path coefficient and Transmodality
print(pLIN)
```

    ##     Estimate 
    ## 3.222325e-07

``` r
# Mediation * Transmodality - final setup for FIGURE 7C
# Map nonsig to grey
bwdf$domnetvecSig<-'NonSig'
# sig where CL_vec indicates
bwdf$domnetvecSig[NL_sigVec]<-as.character(bwdf$domnetvec[NL_sigVec])
# order for plot legend
bwdf$domnetvecSig<-as.factor(bwdf$domnetvecSig)
bwdf$domnetvecSig<-factor(bwdf$domnetvecSig,levels=c("Motor","Visual","DA","VA","Limbic","FP","DM","NonSig"),labels=c("Motor","Visual","DA","VA","Limbic","FP","DM","NonSig."))
```

``` r
ggplot(bwdf,aes(tmvec,AB_Est)) + geom_point(size=6,alpha=.8,aes(color=domnetvecSig))+ scale_color_manual(values=c('#3281ab','#670068','#007500','#b61ad0','#d77d00','#c1253c','gray80')) + xlab("Transmodality") + ylab('AB Path Coefficient') +theme_classic(base_size = 40) +guides(color=guide_legend(title="Yeo 7 Overlap"))+theme(plot.margin=margin(b=3,t=.1,l=.1,r=.1, unit='cm'), legend.position=c(.42,-.24),legend.direction = "horizontal",legend.title=element_text(size=30),legend.text=element_text(size=30))+geom_smooth(method='lm',formula = y~x,color='black')
```

![](Network-level-Mediation_files/figure-markdown_github/unnamed-chunk-11-1.png)

``` r
# FIGURE 7D

# stats for fig-gam
Mediation_net_gam<-gam(AB_Est~s(tmvec,k=3),data=bwdf)
# gams for stats
SMA_gam<-gam(AB_Est~s(scalesvec,k=3),data=bwdf[bwdf$domnetvec17=='Somatomotor A',])
DMB_gam<-gam(AB_Est~s(scalesvec,k=3),data=bwdf[bwdf$domnetvec17=='DM_B',])
summary(SMA_gam)
```

    ## 
    ## Family: gaussian 
    ## Link function: identity 
    ## 
    ## Formula:
    ## AB_Est ~ s(scalesvec, k = 3)
    ## 
    ## Parametric coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept) -0.03975    0.00164  -24.24   <2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Approximate significance of smooth terms:
    ##               edf Ref.df     F p-value    
    ## s(scalesvec) 1.97  1.999 36.72  <2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## R-sq.(adj) =  0.549   Deviance explained = 56.4%
    ## GCV = 0.00017513  Scale est. = 0.00016675  n = 62

``` r
summary(DMB_gam)
```

    ## 
    ## Family: gaussian 
    ## Link function: identity 
    ## 
    ## Formula:
    ## AB_Est ~ s(scalesvec, k = 3)
    ## 
    ## Parametric coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept) 0.018937   0.001729   10.95 5.26e-12 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Approximate significance of smooth terms:
    ##              edf Ref.df    F p-value
    ## s(scalesvec)   1      1 1.02   0.321
    ## 
    ## R-sq.(adj) =  0.000648   Deviance explained = 3.29%
    ## GCV = 0.00010202  Scale est. = 9.5643e-05  n = 32

``` r
# convert yeo17 membership to vector capturing only sig. yeo17 networks, graying out nonsig.
Med_domnetSig17<-domnetvec17
levels(Med_domnetSig17)<-c(levels(Med_domnetSig17),'zNonSig_DM','zNonSig_Mot')
# set nonsigs to de-saturated version of colors
Med_domnetSig17[NL_sigVec==FALSE & Med_domnetSig17 == 'Somatomotor A']='zNonSig_Mot'
Med_domnetSig17[NL_sigVec==FALSE & Med_domnetSig17 == 'DM_B']='zNonSig_DM'

bwdf$Med_domnetSig17<-as.character(Med_domnetSig17)
```

``` r
ggplot(bwdf,aes(scalesvec,AB_Est)) + xlab("# of Networks") + ylab('AB Path Coefficient') +theme_classic(base_size = 40) +guides(alpha=FALSE,color=guide_legend(title="Yeo 17 Overlap"))+theme(legend.position=c(.42,-.2),legend.direction = "horizontal",legend.text = element_text(size=22),legend.title = element_text(size=26))+geom_smooth(data=subset(bwdf,domnetvec17=='Somatomotor A'),method='gam',formula = y~s(x,k=3),aes(color=domnetvec17),fill="gray72")+geom_smooth(data=subset(bwdf,domnetvec17=='DM_B'),method='gam',formula = y~s(x,k=3),aes(color=domnetvec17),fill="gray88")+scale_color_manual(values=c('#bc0943','#4183a8','grey20','grey80'))+geom_point(data=subset(bwdf,domnetvec17=='Somatomotor A'),aes(color=Med_domnetSig17),size=6)+geom_point(data=subset(bwdf,domnetvec17=='DM_B'),aes(color=Med_domnetSig17),size=6)+scale_color_manual(values=c('#bc0943','#4183a8','#ebbecc','#b7d9ed'),labels=c('DM B','SM A','n.s. DM B','n.s. SM A'))+scale_x_continuous(breaks=c(4,10,16,22,28))+theme(plot.margin=unit(c(.9,.6,2,.6),"cm"))
```

    ## Scale for 'colour' is already present. Adding another scale for 'colour',
    ## which will replace the existing scale.

![](Network-level-Mediation_files/figure-markdown_github/unnamed-chunk-13-1.png)
