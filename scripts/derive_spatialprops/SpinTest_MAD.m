% addpaths
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
WorkingFolder = '/cbica/projects/pinesParcels/data/SingleParcellation/SingleAtlas_Analysis';
Variability_Visualize_Folder = [WorkingFolder '/Variability_Visualize'];
% set outdir
outdir='/cbica/projects/pinesParcels/results/aggregated_data/MaskedMADVec_';
% load in SNR masks
surfML = '/cbica/projects/pinesParcels/data/H_SNR_masks/lh.Mask_SNR.label';
mwIndVec_l = read_medial_wall_label(surfML);
surfMR = '/cbica/projects/pinesParcels/data/H_SNR_masks/rh.Mask_SNR.label';
mwIndVec_r = read_medial_wall_label(surfMR);
% for each scale
for K=2:30
	% report K
	disp(K)
	% set output file name
	outFn=strcat('/cbica/projects/pinesParcels/results/aggregated_data/MADPermuts_',num2str(K),'.mat');
	% load in MAD values
        MADFileP = ['/gpfs/fs001/cbica/projects/pinesParcels/data/SingleParcellation/SingleAtlas_Analysis/Variability_Visualize/VariabilityLoading_Median_' num2str(K) 'SystemMean.mat'];
        MADFile=load(MADFileP);
	mad_lh=MADFile.VariabilityLoading_Median_KSystemMean_lh
	mad_rh=MADFile.VariabilityLoading_Median_KSystemMean_rh
	% set mask ROI values to 100 for spin test to catch em as invalid
	mad_lh(mwIndVec_l)=100;
	mad_rh(mwIndVec_r)=100;
	% write them out as a transposed csv for spin test to deal with		
	writetable(table(mad_lh'),[outdir num2str(K) '_L.csv'],'WriteVariableNames',0);
	writetable(table(mad_rh'),[outdir num2str(K),'_R.csv'],'WriteVariableNames',0);
	% create permutations, save out to outFn
	SpinPermuFS([outdir num2str(K) '_L.csv'], [outdir num2str(K) '_R.csv'], 1000, outFn);
end
