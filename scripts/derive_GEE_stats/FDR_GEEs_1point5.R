## dumb quick section just to fdr some p values (from GEEs) because matlab keeps running on of "licenses to FDR" on cubic
Vert_Scale_Ps=read.csv('/cbica/projects/pinesParcels/results/aggregated_data/Scale_GEE_vertPs.csv')
Vert_ScaleAge_Ps=read.csv('/cbica/projects/pinesParcels/results/aggregated_data/AgexScale_GEE_vertPs.csv')
Vert_ScaleEF_Ps=read.csv('/cbica/projects/pinesParcels/results/aggregated_data/EFxScale_GEE_vertPs.csv')

## fdr em
ScaleFDRed=p.adjust(Vert_Scale_Ps$Var1,method='fdr')
ScaleAgeFDRed=p.adjust(Vert_ScaleAge_Ps$Var1,method='fdr')
ScaleEFFDRed=p.adjust(Vert_ScaleEF_Ps$Var1,method='fdr')

## save for matlab friendly format
write.table(ScaleFDRed,'/cbica/projects/pinesParcels/results/EffectVecs/ScaleP_FDRed',sep=',', col.names = F,quote = #F,row.names=F)
write.table(ScaleAgeFDRed,'/cbica/projects/pinesParcels/results/EffectVecs/ScaleAgeP_FDRed',sep=',', col.names = F,quote = #F,row.names=F)
write.table(ScaleEFFDRed,'/cbica/projects/pinesParcels/results/EffectVecs/ScaleEFP_FDRed',sep=',', col.names = F,quote = #F,row.names=F)
