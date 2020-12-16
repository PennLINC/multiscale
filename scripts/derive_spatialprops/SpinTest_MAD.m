% addpaths
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
WorkingFolder = '/cbica/projects/pinesParcels/data/SingleParcellation/SingleAtlas_Analysis';
Variability_Visualize_Folder = [WorkingFolder '/Variability_Visualize'];
% set outdir
outdir='/cbica/projects/pinesParcels/results/aggregated_data/MaskedMADVec_';
% for each scale
for K=2:30
	% report K
	disp(K)
	% set output file name
	outFn=strcat('/cbica/projects/pinesParcels/results/aggregated_data/MADPermuts_',num2str(K),'.mat');
	% load in MAD values
	MADFile=[Variability_Visualize_Folder '/VariabilityLabel_Scale' num2str(K) '.mat'];
	MADKstruct=load(MADFile);
	mad_lh=MADKstruct.VariabilityLabel_lh;
	mad_rh=MADKstruct.VariabilityLabel_rh;
	madk=[mad_lh mad_rh];
	% mask files, set non-mask numbas to 100
	% load in mask (should be the same for all scales)
	Extended_maskFnL=strcat('/cbica/projects/pinesParcels/results/aggregated_data/Border_excludeVec_',num2str(K),'_L.mat');
	Extended_maskFnR=strcat('/cbica/projects/pinesParcels/results/aggregated_data/Border_excludeVec_',num2str(K),'_R.mat');
	Extended_mask_file_L=load(Extended_maskFnL);
	Extended_mask_file_R=load(Extended_maskFnR);
	Extended_mask_L=Extended_mask_file_L.VertexExclude;
	Extended_mask_R=Extended_mask_file_R.VertexExclude;
	% check to make sure all scales ran the same
	if (sum(Extended_mask_L)==1609) && (sum(Extended_mask_R)==1612)
		% set mask ROI values to 100 for spin test to catch em as invalid
		mad_lh(Extended_mask_L==1)=100;
		mad_rh(Extended_mask_R==1)=100;
		% write them out as a transposed csv for spin test to deal with		
		writetable(table(mad_lh'),[outdir num2str(K) '_L.csv'],'WriteVariableNames',0);
		writetable(table(mad_rh'),[outdir num2str(K),'_R.csv'],'WriteVariableNames',0);
		% create permutations, save out to outFn
		SpinPermuFS([outdir num2str(K) '_L.csv'], [outdir num2str(K) '_R.csv'], 1000, outFn);
	else
		disp('You fucked up dummy. Go figure out why the exlusion masks differ')
	end
end
