%%% aggregate mixed effect coefficients from vertex-specific .csvs
% initialize empty vectors
s_Scale=zeros(17734,1);
AgeXScale=zeros(17734,1);
% for p-values, to be FDR'ed
s_Scalep=zeros(17734,1);
AgeXScalep=zeros(17734,1);
% for each vertex
for i=1:17734
	% print vertex number
	disp(i)
	% load in csv
	fn=['/cbica/projects/pinesParcels/results/GEEs/Modeled_GEE_Sex_Mot_s3fxT_AgexScale_v' num2str(i) '_bwVals_overScales.csv'];
	df=readtable(fn);
	% SCALE
        s_Scale(i)=df.s_Scale(1);
        s_Scalep(i)=df.s_Scale(2);
	% AgexScale
        AgeXScale(i)=df.AgeXScale(1);
        AgeXScalep(i)=df.AgeXScale(2);
end
% save out vectors
save('/cbica/projects/pinesParcels/results/aggregated_data/vertices_sScale','s_Scale');
save('/cbica/projects/pinesParcels/results/aggregated_data/vertices_AgeXScale','AgeXScale');
save('/cbica/projects/pinesParcels/results/aggregated_data/vertices_sScalep','s_Scalep');
save('/cbica/projects/pinesParcels/results/aggregated_data/vertices_AgeXScalep','AgeXScalep');
