% just to convert this to an R-reasonable format
gro_partfp=['/cbica/projects/pinesParcels/data/SingleParcellation/SingleAtlas_Analysis/group_all_Ks.mat'];
gro_part=load(gro_partfp);
writetable(table(gro_part.affils),'/cbica/projects/pinesParcels/data/SingleParcellation/SingleAtlas_Analysis/group_all_Ks.csv');
