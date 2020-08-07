% align change in age relation over scales vertex-wise values and transmodality vertex-wise values for density plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add paths
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
% Load in previously calculated age relation change over scales
WOS=load('/cbica/projects/pinesParcels/results/EffectVecs/ageWinCor_x_ScaleCor.mat');
BWOS=load('/cbica/projects/pinesParcels/results/EffectVecs/ageBwCor_x_ScaleCor.mat');
% Load in normative transmodality
ProjectFolder = '/cbica/projects/pinesParcels/data/princ_gradients';
pgl = gifti([ProjectFolder '/Gradients.lh.fsaverage5.func.gii']);
pgr = gifti([ProjectFolder '/Gradients.rh.fsaverage5.func.gii']);

% extract unimodal-transmodal gradient
grad_lh = pgl.cdata(:,1);
grad_rh = pgr.cdata(:,1);

% snr mask on grads
surfML = '/cbica/projects/pinesParcels/data/H_SNR_masks/lh.Mask_SNR.label';
mwIndVec_l = read_medial_wall_label(surfML);
Index_l = setdiff([1:10242], mwIndVec_l);
surfMR = '/cbica/projects/pinesParcels/data/H_SNR_masks/rh.Mask_SNR.label';
mwIndVec_r = read_medial_wall_label(surfMR);
Index_r = setdiff([1:10242], mwIndVec_r);

grad_lh_masked=grad_lh(Index_l);
grad_rh_masked=grad_rh(Index_r);

% Combined Masked TM
CMTM=vertcat(grad_lh_masked,grad_rh_masked);

% vertex info of interest (scale-dependence of its age-Win effect and transmodality)
VertVecs=table(CMTM,WOS.WinAgeEffScalesCor);

writetable(VertVecs,'/cbica/projects/pinesParcels/results/aggregated_data/ScaleAgeWin_TM_interaction.csv');

% same thing but for BW fit
NVertVecs=table(CMTM,BWOS.BwAgeEffScalesCor);

writetable(NVertVecs,'/cbica/projects/pinesParcels/results/aggregated_data/ScaleAgeBw_TM_interaction.csv');
