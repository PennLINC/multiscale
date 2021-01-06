%% MIGHT RUN, CUBIC OUT OF TOOLBOX .LIC WHEN TRIED

% addpaths
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
WorkingFolder = '/cbica/projects/pinesParcels/data/SingleParcellation/SingleAtlas_Analysis';
% set outdir
outdir='/cbica/projects/pinesParcels/results/aggregated_data/';

ProjectFolder = '/cbica/projects/pinesParcels/data/princ_gradients';
% get gradient map
pgl = gifti([ProjectFolder '/Gradients.lh.fsaverage5.func.gii']);
pgr = gifti([ProjectFolder '/Gradients.rh.fsaverage5.func.gii']);
grad_lh = pgl.cdata(:,1);
grad_rh = pgr.cdata(:,1);
pg1=[grad_lh' grad_rh'];

% set output file name
outFn=strcat('/cbica/projects/pinesParcels/results/aggregated_data/PGPermuts.mat');

% load in mask (SNR Mask)
surfML = '/cbica/projects/pinesParcels/data/H_SNR_masks/lh.Mask_SNR.label';
mwIndVec_l = read_medial_wall_label(surfML);
surfMR = '/cbica/projects/pinesParcels/data/H_SNR_masks/rh.Mask_SNR.label';
mwIndVec_r = read_medial_wall_label(surfMR);
grad_lh_lh(mwIndVec_l)=100;
grad_rh(mwIndVec_r)=100;
% check to make sure mask size is appropriate/expected
if ((length(mwIndVec_l))+(length(mwIndVec_r))==(20484-17734))
	% write them out as a csv for spin test to deal with		
	writetable(table(grad_lh),[outdir 'grad_L.csv'],'WriteVariableNames',0);
	writetable(table(grad_rh),[outdir 'grad_R.csv'],'WriteVariableNames',0);
	% create permutations, save out to outFn
	SpinPermuFS([outdir 'grad_L.csv'], [outdir 'grad_R.csv'], 1000, outFn);
else
	disp('You fucked up dummy. Go figure out why the exlusion masks differ')
end
