
   
# matlab spits out FC features to 14 decimal places... there is enough to load without that boggis
library(vroom)
fc<-vroom('/cbica/projects/pinesParcels/results/aggregated_data/fc/master_fcfeats_task.csv')

# set colnames from first row
colnames(fc)<-unlist(fc[1,])

# remove row of colnames
fc<-fc[-c(1),]

# set to match demographics
colnames(fc)[1]<-'bblid'

# round ridiculous number of decimal points
fc[] <- lapply(fc, function(x) {
  if(is.character(x)) round(as.numeric(as.character(x)),digits=3) else x
})

# re-write the rounded version
write.csv(fc,'/cbica/projects/pinesParcels/results/aggregated_data/fc/master_fcfeats_task_rounded.csv')
