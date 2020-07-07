
clear
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
Krange=2:30;
ResultantFolder = '/cbica/projects/pinesParcels/data/SingleParcellation/SingleAtlas_Analysis';
mkdir(ResultantFolder);

SubjectsFolder = '/cbica/software/external/freesurfer/centos7/5.3.0/subjects/fsaverage5';

% for surface data
surfML = '/cbica/projects/pinesParcels/data/H_SNR_masks/lh.Mask_SNR.label'
surfMR = '/cbica/projects/pinesParcels/data/H_SNR_masks/rh.Mask_SNR.label'
mwIndVec_l = read_medial_wall_label(surfML);
Index_l = setdiff([1:10242], mwIndVec_l);
mwIndVec_r = read_medial_wall_label(surfMR);
Index_r = setdiff([1:10242], mwIndVec_r);


for K=Krange;
	K
	SingleAtlasFolder = ['/cbica/projects/pinesParcels/data/SingleParcellation/SingleParcel_1by1_kequal_' num2str(K)];
AllSubjects_AtlasLabelCell = g_ls([SingleAtlasFolder '/*/Indi*/final_UV.mat']);
FinalAtlasLabel_Folder = [ResultantFolder '/FinalAtlasLabel_' num2str(K)];
if ~exist(FinalAtlasLabel_Folder, 'dir')
    mkdir(FinalAtlasLabel_Folder);
end
FinalAtlasLoading_Folder = [ResultantFolder '/FinalAtlasLoading_' num2str(K)];
if ~exist(FinalAtlasLoading_Folder, 'dir')
    mkdir(FinalAtlasLoading_Folder);
end
for i = 1:length(AllSubjects_AtlasLabelCell)
    i
    SingleSubjectParcel = load(AllSubjects_AtlasLabelCell{i});
    sbj_AtlasLoading_NoMedialWall = SingleSubjectParcel.V{1};
    [~, sbj_AtlasLabel_NoMedialWall] = max(sbj_AtlasLoading_NoMedialWall, [], 2);
    sbj_AtlasLabel_lh = zeros(1, 10242);
    sbj_AtlasLoading_lh = zeros(K, 10242);
    sbj_AtlasLabel_lh(Index_l) = sbj_AtlasLabel_NoMedialWall(1:length(Index_l));
    sbj_AtlasLoading_lh(:, Index_l) = sbj_AtlasLoading_NoMedialWall(1:length(Index_l), :)';
    sbj_AtlasLabel_rh = zeros(1, 10242);
    sbj_AtlasLoading_rh = zeros(K, 10242);
    sbj_AtlasLabel_rh(Index_r) = sbj_AtlasLabel_NoMedialWall(length(Index_l) + 1:end);
    sbj_AtlasLoading_rh(:, Index_r) = sbj_AtlasLoading_NoMedialWall(length(Index_l) + 1:end, :)';
    
    [ParentFolder, ~, ~] = fileparts(AllSubjects_AtlasLabelCell{i});
    [ParentFolder, ~, ~] = fileparts(ParentFolder);
    ID_Mat = load([ParentFolder '/ID.mat']);
    save([FinalAtlasLabel_Folder '/' num2str(ID_Mat.ID) '.mat'], 'sbj_AtlasLabel_lh', 'sbj_AtlasLabel_rh', 'sbj_AtlasLabel_NoMedialWall');
    save([FinalAtlasLoading_Folder '/' num2str(ID_Mat.ID) '.mat'], 'sbj_AtlasLoading_lh', 'sbj_AtlasLoading_rh', 'sbj_AtlasLoading_NoMedialWall');
end
end
