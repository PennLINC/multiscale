library(mgcv)
library(ppcor)

# difference in R^2 function
DeltaR2EstVec<-function(x){
  scaledf<-data.frame(cbind(as.numeric(masterdf$Age),as.numeric(masterdf$Sex),masterdf$Motion,x))
  colnames(scaledf)<-c('Age','Sex','Motion','varofint')
  # no-age model (bw ~ sex + motion)
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

# loop over all scales, print out vertexwise DR2s for age
for (K in 2:30){
        print(K)
        # initialize vector to print out DR2's to
        DR2vec=rep(0,17734)
        # read in table printed out from matlab on cubic
        file=paste('/home/pinesa/VertexwiseTables_forDR2/Scale_',K,'_vertices_bw_allscales.csv',sep='')
        data=read.csv(file)
        print('Data Loaded')
        masterdf=data.frame(data)
        colnames(masterdf)[1:3]=c('Age','Motion','Sex')
        # loop over every vertex
        for (V in 1:17734){
                # +3 because first 3 columns are other covariates
                DR2vec[V]=DeltaR2EstVec(masterdf[,V+3])
        }
        print('18K gams for this scale run')
        # print out DR2 vec for this scale
        writeoutname=paste('/home/pinesa/VertexwiseTables_forDR2/Scale',K,'_AgeBw_VertDR2s.csv',sep='')
        write.csv(DR2vec,writeoutname)
}
