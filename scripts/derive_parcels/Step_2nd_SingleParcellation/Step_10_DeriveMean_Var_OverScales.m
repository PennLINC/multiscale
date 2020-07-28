function Step_10_DeriveMean_Var_OverScales()
% Just get mean variability values over variability maps calculated in step 9.1 (over scales, for HP and soft P)
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
WorkingFolder = '/cbica/projects/pinesParcels/data/SingleParcellation/SingleAtlas_Analysis';
SubjectsFolder = '/cbica/software/external/freesurfer/centos7/5.3.0/subjects/fsaverage5';
Variability_Visualize_Folder = [WorkingFolder '/Variability_Visualize'];

% for surface data
surfML = '/cbica/projects/pinesParcels/data/H_SNR_masks/lh.Mask_SNR.label'
surfMR = '/cbica/projects/pinesParcels/data/H_SNR_masks/rh.Mask_SNR.label'
mwIndVec_l = read_medial_wall_label(surfML);
Index_l = setdiff([1:10242], mwIndVec_l);
mwIndVec_r = read_medial_wall_label(surfMR);
Index_r = setdiff([1:10242], mwIndVec_r);

Krange=2:30;
% empty array to store hard and soft var over all scales
Earray=zeros(length(Krange),2);

for K=2:30;
	% Soft Variability (Loadings)
	SVFN=[Variability_Visualize_Folder '/VariabilityLoading_Median_' num2str(K) 'SystemMean.mat'];
	SoftStruct=load(SVFN);
	SoftVar=SoftStruct.VariabilityLoading_Median_KSystemMean_NoMedialWall;
	MeanSoftVar=mean(SoftVar);
	Earray(K-1,1)=MeanSoftVar;
	% Hard Variability (Labels)
	HVFN=[Variability_Visualize_Folder '/VariabilityLabel_Scale' num2str(K) '.mat'];
	HardStruct=load(HVFN);
        HardVar=HardStruct.VariabilityLabel_NoMedialWall;
        MeanHardVar=mean(HardVar);
	Earray(K-1,2)=MeanHardVar;
end
writetable(table(Earray),'/cbica/projects/pinesParcels/results/aggregated_data/Variability_overScales.csv');
