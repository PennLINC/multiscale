addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
ProjectFolder = '/cbica/projects/pinesParcels/data/SingleParcellation';
outdirp='/cbica/projects/pinesParcels/results/aggregated_data/ind_parcoef.mat';
outdirgp='/cbica/projects/pinesParcels/results/aggregated_data/gro_parcoef.mat';
Krange=2:30;
subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');

group_parts=load([ProjectFolder '/SingleAtlas_Analysis/group_all_Ks.mat']);
group_parts=group_parts.affils;
% load in SNR masks
l_l = read_label([],'/cbica/projects/pinesParcels/data/H_SNR_masks/lh.Mask_SNR.label');
l_r = read_label([],'/cbica/projects/pinesParcels/data/H_SNR_masks/rh.Mask_SNR.label');
% assuming +1 is because matlab starts on 1, not 0. can double-check with zc
l_l_ind = l_l(:,1) + 1;
l_r_ind = l_r(:,1) + 1;
% change mask from 0s from 1 at shitty vertices to 0
surfMask.l = ones(10242,1);
surfMask.l(l_l_ind) = 0;
surfMask.r = ones(10242,1);
surfMask.r(l_r_ind) = 0;

% group partitions for comparison to single-subject
group_parts=load([ProjectFolder '/SingleAtlas_Analysis/group_all_Ks.mat']);
group_parts=group_parts.affils;
group_parts_masked=group_parts(any(group_parts,2),:);

for s=1:length(subjs);
	s
	% Make empty vertex-level participation coefficient vector (# vert in mask, ~=fsaverage5)
	partcoefpos=zeros(17734,length(Krange),length(subjs));
	partcoefneg=zeros(17734,length(Krange),length(subjs));
	gpartcoefpos=zeros(17734,length(Krange),length(subjs));
	gpartcoefneg=zeros(17734,length(Krange),length(subjs));	
	
        vw_ts_l_p=['/cbica/projects/pinesParcels/data/CombinedData/' num2str(subjs(s)) '/lh.fs5.sm6.residualised.mgh'];
	vw_ts_r_p=['/cbica/projects/pinesParcels/data/CombinedData/' num2str(subjs(s)) '/rh.fs5.sm6.residualised.mgh'];
	vw_ts_l=MRIread(vw_ts_l_p);
	vw_ts_r=MRIread(vw_ts_r_p);
	vw_ts_l=vw_ts_l.vol;
	vw_ts_r=vw_ts_r.vol;
	% apply SNR masks
	vw_ts_l_masked=vw_ts_l(1,(logical(surfMask.l)),1,:);
	vw_ts_r_masked=vw_ts_r(1,(logical(surfMask.r)),1,:);
	% stacking matrices so vertex number is doubled (not timepoints obvi)
	vw_ts_both=[vw_ts_l_masked vw_ts_r_masked];
	vw_ts_bothrw=zeros(555,17734);
	for x=1:length(vw_ts_bothrw)
		vw_ts_bothrw(:,x)=vw_ts_both(1,x,1,:);
	end
	% bigass connectivity matrix, takes 5 seconds or so to calc
	ba_conmat=corrcoef(vw_ts_bothrw);
	% for each scale
	for K=2:max(Krange)
		K
		tic
		% load in partitions
		K_Folder = ['/cbica/projects/pinesParcels/data/SingleParcellation/SingleParcel_1by1_kequal_' num2str(K) '/Sub_' num2str(subjs(s))];
		K_part_subj =[K_Folder '/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_1_alphaL10_vxInfo1_ard0_eta0/final_UV.mat'];
		subj_part=load(K_part_subj);
		% do not see automated subject-level soft-parcel -> hard-parcel script... can double-check with zc
		%%% convert to HP - V for vert x K
		subj_V=subj_part.V{1};
		% new column for HP label, K+1 because there should be K loading columns, so the last column becomes labels
		subj_V(:,K+1)=zeros(1,length(subj_V));
		[ ~ , subj_V(:,K+1)]=max(subj_V,[],2); 
		% evaluate group consensus in parallel, k-1 because partitions start at 2
		group_part=group_parts_masked(:,K-1);	
		% small section to get vertex-wise participation coefficients for this this subject at this scale
		[pospc, negpc] = participation_coef_sign(ba_conmat,subj_V(:,K+1));
		[gpospc, gnegpc] = participation_coef_sign(ba_conmat,group_part);

		% K-1 because K starts at 2, pcoef arrays starts at 1
		partcoefpos(:,K-1,s)=pospc;
		partcoefneg(:,K-1,s)=negpc;
		gpartcoefpos(:,K-1,s)=gpospc;
		gpartcoefneg(:,K-1,s)=gnegpc;	
		toc
	end
end
% save files to subjdir
subjpcs=struct('partcoefpos',num2cell(partcoefpos),'partcoefneg',num2cell(partcoefneg));
subjgpcs=struct('partcoefpos',num2cell(partcoefpos),'partcoefneg',num2cell(partcoefneg));
save(outdirp,'subjpcs')
save(outdirgp,'subjgpcs') 
