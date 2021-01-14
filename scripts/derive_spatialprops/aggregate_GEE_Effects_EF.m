%%% aggregate mixed effect coefficients from vertex-specific .csvs
% initialize empty vectors
EFXScale=zeros(17734,1);
% for p-values, to be FDR'ed
EFXScalep=zeros(17734,1);
% for each vertex
for i=1:17734
	% print vertex number
	disp(i)
	% load in csv
	fn=['/cbica/projects/pinesParcels/results/GEEs/Modeled_GEE_Sex_Mot_s3fxT_AgexScale_EFxScale_v' num2str(i) '_bwVals_overScales.csv'];
	df=readtable(fn);
	% EFxScale
        EFXScale(i)=df.EFxScale(1);
        EFXScalep(i)=df.EFxScale(2);
end
% save out vectors
save('/cbica/projects/pinesParcels/results/aggregated_data/vertices_EFXScale','EFXScale');
save('/cbica/projects/pinesParcels/results/aggregated_data/vertices_EFXScalep','EFXScalep');
