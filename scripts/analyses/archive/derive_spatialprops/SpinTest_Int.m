% addpaths
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
WorkingFolder = '/cbica/projects/pinesParcels/data/SingleParcellation/SingleAtlas_Analysis';
% set outdir
outdir='/cbica/projects/pinesParcels/results/aggregated_data/';
% set output file name
outFn=strcat('/cbica/projects/pinesParcels/results/aggregated_data/IntPermuts.mat');
% load in Int values
IntFile=['/cbica/projects/pinesParcels/results/AvgIntercept'];
Intstruct=load(IntFile);
Int_merged=Intstruct.datalr;
% mask files, set non-mask numbas to 100
% load in mask (should be the same for all scales)
Intstruct=load(IntFile);
int_lh=Intstruct.datalr(1:10242);
int_rh=Intstruct.datalr(10243:20484);
%%% get real correlation
% load in mask (SNR Mask)
surfML = '/cbica/projects/pinesParcels/data/H_SNR_masks/lh.Mask_SNR.label';
mwIndVec_l = read_medial_wall_label(surfML);
surfMR = '/cbica/projects/pinesParcels/data/H_SNR_masks/rh.Mask_SNR.label';
mwIndVec_r = read_medial_wall_label(surfMR);
int_lh(mwIndVec_l)=100;
int_rh(mwIndVec_r)=100;
int_merged=[int_lh int_rh];	
% check to make sure mask size is appropriate/expected
if ((length(mwIndVec_l))+(length(mwIndVec_r))==(20484-17734))
	% write them out as a transposed csv for spin test to deal with		
	writetable(table(int_lh'),[outdir 'Int_L.csv'],'WriteVariableNames',0);
	writetable(table(int_rh'),[outdir 'Int_R.csv'],'WriteVariableNames',0);
	% create permutations, save out to outFn
	SpinPermuFS([outdir 'Int_L.csv'], [outdir 'Int_R.csv'], 1000, outFn);
else
	disp('You fucked up dummy. Go figure out why the exlusion masks differ')
end
