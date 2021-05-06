%%% aggregate vertex-wise change over scales, print out in R friendly format
% addpaths
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
% set paths
ProjectFolder = '/cbica/projects/pinesParcels/data/princ_gradients';

% get gradients
pgl = gifti([ProjectFolder '/Gradients.lh.fsaverage5.func.gii']);
pgr = gifti([ProjectFolder '/Gradients.rh.fsaverage5.func.gii']);

% extract unimodal-transmodal gradient
grad_lh = pgl.cdata(:,1)';
grad_rh = pgr.cdata(:,1)';




WorkingFolder = '/cbica/projects/pinesParcels/data/SingleParcellation/SingleAtlas_Analysis';
Variability_Visualize_Folder = [WorkingFolder '/Variability_Visualize'];
% load in to exclude border vertices
borderVertsfileL=load('/gpfs/fs001/cbica/projects/pinesParcels/results/aggregated_data/Border_excludeVec_2_L.mat');
borderVertsfileR=load('/gpfs/fs001/cbica/projects/pinesParcels/results/aggregated_data/Border_excludeVec_2_R.mat');
borderVertsL=borderVertsfileL.VertexExclude;
borderVertsR=borderVertsfileR.VertexExclude;
% convert to vertex indices to tag onto mask
bordIndL=find(borderVertsL);
bordIndR=find(borderVertsR);
surfML = '/cbica/projects/pinesParcels/data/H_SNR_masks/lh.Mask_SNR.label';
mwIndVec_l = read_medial_wall_label(surfML);
mwIndVec_bord_l = vertcat(mwIndVec_l,bordIndL');
Index_l = setdiff([1:10242], mwIndVec_bord_l);
surfMR = '/cbica/projects/pinesParcels/data/H_SNR_masks/rh.Mask_SNR.label';
mwIndVec_r = read_medial_wall_label(surfMR);
mwIndVec_bord_r = vertcat(mwIndVec_r,bordIndR');
Index_r = setdiff([1:10242], mwIndVec_bord_r);

% initialize array (1 for each hemi, can merge later in R)
% 30 columns for 29 scales and PG1
LHPGVecs=grad_lh(Index_l);
RHPGVecs=grad_rh(Index_r);

% save out files in r-friendlty format
writetable(table(LHPGVecs),'/cbica/projects/pinesParcels/results/aggregated_data/vertexWisePG_LH.csv');
writetable(table(RHPGVecs),'/cbica/projects/pinesParcels/results/aggregated_data/vertexWisePG_RH.csv');
