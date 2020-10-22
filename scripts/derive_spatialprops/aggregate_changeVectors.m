%%% aggregate vertex-wise change over scales, print out in R friendly format
% addpaths
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
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
Index_l = setdiff([1:10242], mwIndVec_l);
surfMR = '/cbica/projects/pinesParcels/data/H_SNR_masks/rh.Mask_SNR.label';
mwIndVec_r = read_medial_wall_label(surfMR);
mwIndVec_bord_r = vertcat(mwIndVec_r,bordIndR');
Index_r = setdiff([1:10242], mwIndVec_r);

% initialize array (1 for each hemi, can merge later in R)
% 30 columns for 29 scales and PG1
LHchangeVecs=zeros(length(Index_l),30);
RHchangeVecs=zeros(length(Index_r),30);

% for both hemispheres
hemilist=["L", "R"];
for h=1:2;
	% load in PG1 vec
	fn=strcat('/cbica/projects/pinesParcels/results/aggregated_data/changeVec_PG1_',hemilist(h),'.mat');
	a=load(fn);
	if (h==1)
		LHchangeVecs(:,1)=a.VertexChange(Index_l);
	elseif (h==2)
		RHchangeVecs(:,1)=a.VertexChange(Index_r);
	end

	% load in vectors at each scale
	for K=2:30
		fn=strcat('/cbica/projects/pinesParcels/results/aggregated_data/changeVec_',num2str(K),'_',hemilist(h),'.mat');
		a=load(fn);
		if (h==1)
			LHchangeVecs(:,K)=a.VertexChange(Index_l);
		elseif (h==2)
			RHchangeVecs(:,K)=a.VertexChange(Index_r);
		end
	end
end
% save out files in r-friendlty format
writetable(table(LHchangeVecs),'/cbica/projects/pinesParcels/results/aggregated_data/vertexWiseChange_LH.csv');
writetable(table(RHchangeVecs),'/cbica/projects/pinesParcels/results/aggregated_data/vertexWiseChange_RH.csv');
