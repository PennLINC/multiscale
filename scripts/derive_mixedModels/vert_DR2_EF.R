library(mgcv)
library(ppcor)

# difference in R^2 function
DeltaR2EstVec<-function(x){
  # relevant df
  scaledf<-data.frame(cbind(as.numeric(masteref$EF),as.numeric(masteref$Age),as.numeric(masteref$Sex),masteref$Motion,x))
  colnames(scaledf)<-c('EF','Age','Sex','Motion','varofint')
  
  # no-EF model (segreg ~ sex + motion)
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

# for p-values
EFDeltaPEstVec<-function(x){
  
  # relevant df
  scaledf<-data.frame(cbind(as.numeric(masteref$EF),as.numeric(masteref$Age),as.numeric(masteref$Sex),masteref$Motion,x))
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

# loop over all scales, print out vertexwise DR2s for EF
for (K in 2:30){
	print(K)
	# initialize vector to print out DR2's to
	DR2vec=rep(0,17734)
	Pvec=rep(0,17734)
	# read in table printed out from matlab on cubic
	file=paste('/home/pinesa/VertexwiseTables_forDR2/Scale_',K,'_vertices_bw_allscales_EF.csv',sep='')
	data=read.csv(file)
	print('Data Loaded')
	masteref=data.frame(data)
	colnames(masteref)[1:4]=c('EF','Age','Motion','Sex')
	# loop over every vertex
	for (V in 1:17734){
		# +3 because first 4 columns are other covariates
		DR2vec[V]=DeltaR2EstVec(masteref[,V+4])
		Pvec[V]=EFDeltaPEstVec(masteref[,V+4])
	}
	print('18K gams for this scale run')
	# print out DR2 vec for this scale
	writeoutname=paste('/home/pinesa/VertexwiseTables_forDR2/Scale',K,'_EFBw_VertDR2s.csv',sep='')
	write.csv(DR2vec,writeoutname)
        # print out DR2 vec for this scale
        writeoutname=paste('/home/pinesa/VertexwiseTables_forDR2/Scale',K,'_EFBw_VertPs.csv',sep='')
        write.csv(Pvec,writeoutname)
}
