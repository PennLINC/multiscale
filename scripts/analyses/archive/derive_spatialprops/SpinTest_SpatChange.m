% addpaths
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
% set outdir
outdir='/cbica/projects/pinesParcels/results/aggregated_data/MaskedChangeVec_';
% for each scale
for K=2:30
	% report K
	disp(K)
	% set output file name
	outFn=strcat('/cbica/projects/pinesParcels/results/aggregated_data/SpatChangePermuts_',num2str(K),'.mat');
	% load in change values
	changeValsFnL=strcat('/cbica/projects/pinesParcels/results/aggregated_data/changeVec_',num2str(K),'_L.mat');
	changeValsFnR=strcat('/cbica/projects/pinesParcels/results/aggregated_data/changeVec_',num2str(K),'_R.mat');
	changeValsL_file=load(changeValsFnL);
	changeValsR_file=load(changeValsFnR);
	changeValsL=changeValsL_file.VertexChange;
	changeValsR=changeValsR_file.VertexChange;
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
		changeValsL(Extended_mask_L==1)=100;
		changeValsR(Extended_mask_R==1)=100;
		% write them out as a transposed csv for spin test to deal with		
		writetable(table(changeValsL'),[outdir num2str(K) '_L.csv'],'WriteVariableNames',0);
		writetable(table(changeValsR'),[outdir num2str(K),'_R.csv'],'WriteVariableNames',0);
		% create permutations, save out to outFn
		SpinPermuFS([outdir num2str(K) '_L.csv'], [outdir num2str(K) '_R.csv'], 1000, outFn);
	else
		disp('You fucked up dummy. Go figure out why the exlusion masks differ')
	end
end
