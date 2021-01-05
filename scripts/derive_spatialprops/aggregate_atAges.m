%%% aggregate vertex-wise change over scales, print out in R friendly format
% addpaths
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
% set paths
ProjectFolder = '/cbica/projects/pinesParcels/data/princ_gradients';

NormAt10=load('/cbica/projects/pinesParcels/results/BW_InterceptAt10_k');
NormAt21=load('/cbica/projects/pinesParcels/results/BW_InterceptAt21_k');




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

% L R splits
L10=NormAt21.datalr(:,1);
R10=NormAt10.datalr(:,2);
L21=NormAt21.datalr(:,1);
R21=NormAt21.datalr(:,2);
% 10
LH_10_Vecs=L10(Index_l);
RH_10_Vecs=R10(Index_r);
LH_21_Vecs=L21(Index_l);
RH_21_Vecs=R21(Index_r);

% save out files in r-friendlty format
writetable(table(LH_10_Vecs),'/cbica/projects/pinesParcels/results/aggregated_data/vertexWise_10_LH.csv');
writetable(table(RH_10_Vecs),'/cbica/projects/pinesParcels/results/aggregated_data/vertexWise_10_RH.csv');
writetable(table(LH_21_Vecs),'/cbica/projects/pinesParcels/results/aggregated_data/vertexWise_21_LH.csv');
writetable(table(RH_21_Vecs),'/cbica/projects/pinesParcels/results/aggregated_data/vertexWise_21_RH.csv');
