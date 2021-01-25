% load it all in
Scalefn='/cbica/projects/pinesParcels/results/aggregated_data/vertices_sScale';
ScalefnP='/cbica/projects/pinesParcels/results/aggregated_data/vertices_sScalep';
ScaleAgefn='/cbica/projects/pinesParcels/results/aggregated_data/vertices_AgeXScale';
ScaleAgefnP='/cbica/projects/pinesParcels/results/aggregated_data/vertices_AgeXScalep';
ScaleEFfn='/cbica/projects/pinesParcels/results/aggregated_data/vertices_EFXScale';
ScaleEFfnP='/cbica/projects/pinesParcels/results/aggregated_data/vertices_EFXScalep';
Scale=load(Scalefn);
ScaleP=load(ScalefnP);
ScaleAge=load(ScaleAgefn);
ScaleAgeP=load(ScaleAgefnP);
ScaleEF=load(ScaleEFfn);
ScaleEFP=load(ScaleEFfnP);

% Part I - save em out in r-friendly format
writetable(table(ScaleP.s_Scalep),'/cbica/projects/pinesParcels/results/aggregated_data/Scale_GEE_vertPs.csv');
writetable(table(ScaleAgeP.AgeXScalep),'/cbica/projects/pinesParcels/results/aggregated_data/AgexScale_GEE_vertPs.csv');
writetable(table(ScaleEFP.EFXScalep),'/cbica/projects/pinesParcels/results/aggregated_data/EFxScale_GEE_vertPs.csv');

