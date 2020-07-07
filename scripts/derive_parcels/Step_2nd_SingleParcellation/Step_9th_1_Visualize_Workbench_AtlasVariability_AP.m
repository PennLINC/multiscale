
%
% For variability of probability atlas:
% Using MADM=median(|x(i) - median(x)|) to calculate variability
% For variability of hard label atlas:
% See: 
%   https://stats.stackexchange.com/questions/221332/variance-of-a-distribution-of-multi-level-categorical-data
%

addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
WorkingFolder = '/cbica/projects/pinesParcels/data/SingleParcellation/SingleAtlas_Analysis';
SubjectsFolder = '/cbica/software/external/freesurfer/centos7/5.3.0/subjects/fsaverage5';

% for surface data
surfML = '/cbica/projects/pinesParcels/data/H_SNR_masks/lh.Mask_SNR.label'
surfMR = '/cbica/projects/pinesParcels/data/H_SNR_masks/rh.Mask_SNR.label'
mwIndVec_l = read_medial_wall_label(surfML);
Index_l = setdiff([1:10242], mwIndVec_l);
mwIndVec_r = read_medial_wall_label(surfMR);
Index_r = setdiff([1:10242], mwIndVec_r);

Krange=2:30;

for K=2:30;
%
% Variability of probability atlas
%
LoadingFolder = [WorkingFolder '/FinalAtlasLoading_' num2str(K)];
DataCell = g_ls([LoadingFolder '/*.mat']);
for i = 1:length(DataCell)
  i
  tmp = load(DataCell{i});
  for j = 1:K
    cmd = ['sbj_Loading_lh_Matrix_' num2str(j) '(i, :) = tmp.sbj_AtlasLoading_lh(j, :);'];
    eval(cmd);
    cmd = ['sbj_Loading_rh_Matrix_' num2str(j) '(i, :) = tmp.sbj_AtlasLoading_rh(j, :);'];
    eval(cmd);
  end
end
%
Variability_Visualize_Folder = [WorkingFolder '/Variability_Visualize'];
mkdir(Variability_Visualize_Folder);
Variability_All_lh = zeros(K, 10242);
Variability_All_rh = zeros(K, 10242);
for m = 1:K
  m
  for n = 1:10242
    % left hemi
    cmd = ['tmp_data = sbj_Loading_lh_Matrix_' num2str(m) '(:, n);'];
    eval(cmd);
    Variability_lh(n) = median(abs(tmp_data - median(tmp_data)));
    eval(cmd);
    % right hemi
    cmd = ['tmp_data = sbj_Loading_rh_Matrix_' num2str(m) '(:, n);'];
    eval(cmd);
    Variability_rh(n) = median(abs(tmp_data - median(tmp_data)));
  end

  % write to files
  V_lh = gifti;
  V_lh.cdata = Variability_lh';
  V_lh_File = [Variability_Visualize_Folder '/Variability_lh_' num2str(m) '.func.gii'];
  save(V_lh, V_lh_File);
  V_rh = gifti;
  V_rh.cdata = Variability_rh';
  V_rh_File = [Variability_Visualize_Folder '/Variability_rh_' num2str(m) '.func.gii'];
  save(V_rh, V_rh_File);
  % convert into cifti file
  cmd = ['wb_command -cifti-create-dense-scalar ' Variability_Visualize_Folder '/Variability_Scale' num2str(K) '_' num2str(m) ...
         '.dscalar.nii -left-metric ' V_lh_File ' -right-metric ' V_rh_File];
  system(cmd);
  pause(1);
  system(['rm -rf ' V_lh_File ' ' V_rh_File]);
 
  Variability_All_lh(m, :) = Variability_lh;
  Variability_All_rh(m, :) = Variability_rh;
end
Variability_All_NoMedialWall = [Variability_All_lh(:, Index_l) Variability_All_rh(:, Index_r)];
save([Variability_Visualize_Folder '/VariabilityLoading.mat'], 'Variability_All_lh', 'Variability_All_rh', 'Variability_All_NoMedialWall');
% K system mean
VariabilityLoading_Median_KSystemMean_lh = mean(Variability_All_lh);
VariabilityLoading_Median_KSystemMean_rh = mean(Variability_All_rh);
V_lh = gifti;
V_lh.cdata = VariabilityLoading_Median_KSystemMean_lh';
V_lh_File = [Variability_Visualize_Folder '/VariabilityLoading_' num2str(K) 'SystemMean_lh.func.gii'];
save(V_lh, V_lh_File);
V_rh = gifti;
V_rh.cdata = VariabilityLoading_Median_KSystemMean_rh';
V_rh_File = [Variability_Visualize_Folder '/VariabilityLoading_' num2str(K) 'SystemMean_rh.func.gii'];
save(V_rh, V_rh_File);
cmd = ['wb_command -cifti-create-dense-scalar ' Variability_Visualize_Folder '/VariabilityLoading_' num2str(K) 'SystemMean' ...
       '.dscalar.nii -left-metric ' V_lh_File ' -right-metric ' V_rh_File];
system(cmd);
pause(1);
system(['rm -rf ' V_lh_File ' ' V_rh_File]);
% Save average variability of K system 
VariabilityLoading_Median_KSystemMean_NoMedialWall = [VariabilityLoading_Median_KSystemMean_lh(Index_l) ...
    VariabilityLoading_Median_KSystemMean_rh(Index_r)];
save([Variability_Visualize_Folder '/VariabilityLoading_Median_' num2str(K) 'SystemMean.mat'], ...
    'VariabilityLoading_Median_KSystemMean_lh', 'VariabilityLoading_Median_KSystemMean_rh', ...
    'VariabilityLoading_Median_KSystemMean_NoMedialWall');

%
% Variability of hard parcellation atlas
%
LabelFolder = [WorkingFolder '/FinalAtlasLabel_' num2str(K)];
DataCell = g_ls([LabelFolder '/*.mat']);
for i = 1:length(DataCell)
  i
  tmp = load(DataCell{i});
  sbj_AtlasLabel_lh_Matrix(i, :) = tmp.sbj_AtlasLabel_lh;
  sbj_AtlasLabel_rh_Matrix(i, :) = tmp.sbj_AtlasLabel_rh;
end
for m = 1:10242
  m
  for n = 1:K
    % left hemi
    Probability_lh(m, n) = length(find(sbj_AtlasLabel_lh_Matrix(:, m) == n)) / 693;
    Probability_lh(m, n) = Probability_lh(m, n) * log2(Probability_lh(m, n));
    % right hemi
    Probability_rh(m, n) = length(find(sbj_AtlasLabel_rh_Matrix(:, m) == n)) / 693;
    Probability_rh(m, n) = Probability_rh(m, n) * log2(Probability_rh(m, n));
  end
  Probability_lh(find(isnan(Probability_lh))) = 0;
  Probability_rh(find(isnan(Probability_rh))) = 0;
  VariabilityLabel_lh(m) = -sum(Probability_lh(m, :));
  VariabilityLabel_rh(m) = -sum(Probability_rh(m, :));
end
VariabilityLabel_NoMedialWall = [VariabilityLabel_lh(Index_l) VariabilityLabel_rh(Index_r)];
save([Variability_Visualize_Folder '/VariabilityLabel_Scale' num2str(K) '.mat'], 'VariabilityLabel_lh', 'VariabilityLabel_rh', 'VariabilityLabel_NoMedialWall');

% For visualization
V_lh = gifti;
V_lh.cdata = VariabilityLabel_lh';
V_lh_File = [Variability_Visualize_Folder '/VariabilityLabel_Scale' num2str(K) '_lh.func.gii'];
save(V_lh, V_lh_File);
V_rh = gifti;
V_rh.cdata = VariabilityLabel_rh';
V_rh_File = [Variability_Visualize_Folder '/VariabilityLabel_Scale' num2str(K) '_rh.func.gii'];
save(V_rh, V_rh_File);
cmd = ['wb_command -cifti-create-dense-scalar ' Variability_Visualize_Folder '/VariabilityLabel_Scale' num2str(K) ...
       '.dscalar.nii -left-metric ' V_lh_File ' -right-metric ' V_rh_File];
system(cmd);
system(['rm -rf ' V_lh_File ' ' V_rh_File]);
K
end
