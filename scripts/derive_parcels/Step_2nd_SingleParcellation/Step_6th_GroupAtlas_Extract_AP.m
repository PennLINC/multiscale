
% commented clear out so K can penetrate
%clear
Folder = '/cbica/projects/pinesParcels/data/SingleParcellation';

%% Group atlas was the clustering results of 50 atlases during the initialization
GroupAtlasLoading_Mat = load([Folder '/RobustInitialization_' num2str(K) '/init.mat']);

SubjectsFolder = '/cbica/software/external/freesurfer/centos7/5.3.0/subjects/fsaverage5';
% for surface data
surfML = '/cbica/projects/pinesParcels/data/H_SNR_masks/lh.Mask_SNR.label';
mwIndVec_l = read_medial_wall_label(surfML);
Index_l = setdiff([1:10242], mwIndVec_l);
surfMR = '/cbica/projects/pinesParcels/data/H_SNR_masks/rh.Mask_SNR.label';
mwIndVec_r = read_medial_wall_label(surfMR);
Index_r = setdiff([1:10242], mwIndVec_r);

initV = GroupAtlasLoading_Mat.initV;
initV_Max = max(initV);
trimInd = initV ./ max(repmat(initV_Max, size(initV, 1), 1), eps) < 5e-2;
initV(trimInd) = 0;
sbj_AtlasLoading_NoMedialWall = initV;
[~, sbj_AtlasLabel_NoMedialWall] = max(sbj_AtlasLoading_NoMedialWall, [], 2);

sbj_AtlasLabel_lh = zeros(1, 10242);
sbj_AtlasLoading_lh = zeros(K, 10242);
sbj_AtlasLabel_lh(Index_l) = sbj_AtlasLabel_NoMedialWall(1:length(Index_l));
sbj_AtlasLoading_lh(:, Index_l) = sbj_AtlasLoading_NoMedialWall(1:length(Index_l), :)';
sbj_AtlasLabel_rh = zeros(1, 10242);
sbj_AtlasLoading_rh = zeros(K, 10242);
sbj_AtlasLabel_rh(Index_r) = sbj_AtlasLabel_NoMedialWall(length(Index_l) + 1:end);
sbj_AtlasLoading_rh(:, Index_r) = sbj_AtlasLoading_NoMedialWall(length(Index_l) + 1:end, :)';

save([Folder '/SingleAtlas_Analysis/Group_AtlasLabel_' num2str(K) '.mat'], 'sbj_AtlasLabel_lh', 'sbj_AtlasLabel_rh', 'sbj_AtlasLabel_NoMedialWall');
save([Folder '/SingleAtlas_Analysis/Group_AtlasLoading_' num2str(K) '.mat'], 'sbj_AtlasLoading_lh', 'sbj_AtlasLoading_rh', 'sbj_AtlasLoading_NoMedialWall');

