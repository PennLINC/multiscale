### Bootstrap corr((corr MAD*PG),scale)
v=commandArgs(trailingOnly=TRUE)
set.seed(v)
# initialize array of betas to store (1,000x1)
BetaArray<-seq(1,1000)
# scale variable
scale=seq(2:30)
for (b in 1:50){
	# to monitor progress
	print(b)
	# get subject resample indices
	BootInd<-sample(seq(1,693),693,replace=T)
	# Save Boot indices for reading in matlab
	write.table(BootInd,paste0('/cbica/projects/pinesParcels/results/BootIndices',v,'.csv'),col.names=F,row.names=F)
	# save v variable entry for pasting into matlab command
	vVar=paste0('v=',v)
	command=paste0("matlab -nodisplay -r '",vVar,";run(\"/cbica/projects/pinesParcels/multiscale/scripts/derive_spatialprops/Boot_MADPGCorr\")'")
	# calculate MAD according to subj. resample indices
	system(command)
	#system("matlab -nodisplay -r 'run(\"/cbica/projects/pinesParcels/multiscale/scripts/derive_spatialprops/Boot_MADPGCorr\")'")
	# read in bootstrapped corr estimates for each scale
	CsvName=paste0('/cbica/projects/pinesParcels/results/Boot_MADPGCorr_acrossScales',v,'.csv')
	BootCsv<-read.csv(CsvName,header=F)
	BootVals<-unlist(BootCsv[1,])
	BootLM<-lm(scale~BootVals)
	# get beta coef. for lm fitting scale to PG*MAD cor
	beta<-BootLM$coefficients[2]
	# insert into beta array	
	BetaArray[b]<-beta
}
# save beta array for Vertex-level-MAD_PG.md
write.table(BetaArray,paste0('PGMAD_Boot_ScaleBetas',v,'.csv'))
