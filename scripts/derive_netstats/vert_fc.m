%iterate over subjects to get within and between network connectivities for each scale (K)

% add needed paths
addpath(genpath('/cbica/projects/pinesParcels/scripts/derive_parcels/Toolbox'));

ProjectFolder = '/cbica/projects/pinesParcels/data/SingleParcellation';

% What is K range to iterate over?
% I'll tell you hwhat
Krange=2:30;
% Read in subjects list
subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');
% read in group partitions % TO DO - AUGMENT SCRIPT TO COMBINE ALL GROUP PARTS INTO A SINGLE .MAT
group_parts=load;i
% check to make sure dimensions match

% load in SNR masks
l_l = read_label([],'/cbica/projects/pinesParcels/data/H_SNR_masks/lh.Mask_SNR.label');
l_r = read_label([],'/cbica/projects/pinesParcels/data/H_SNR_masks/rh.Mask_SNR.label');

% assuming +1 is because matlab starts on 1, not 0. can double-check with zc
l_l_ind = l_l(:,1) + 1;
l_r_ind = l_r(:,1) + 1;

% for each subject
for s=1:length(subjs)
	% load in vertex-wise time series
	vw_ts_l_p=['/cbica/projects/pinesParcels/data/CombinedData/' num2str(subjs(s)) '/lh.fs5.sm6.residualised.mgh']
	vw_ts_r_p=['/cbica/projects/pinesParcels/data/CombinedData/' num2str(subjs(s)) '/rh.fs5.sm6.residualised.mgh']
	vw_ts_l=MRIread(vw_ts_l_p);
	vw_ts_r=MRIread(vw_ts_r_p);
	vw_ts_l=vw_ts_l.vol;
	vw_ts_r=vw_ts_r.vol;
	% apply SNR masks
	vw_ts_l_masked=vw_ts_l(surfMask.l);
	vw_ts_r_masked=vw_ts_r(surfMask.r);
	% stacking matrices so vertex number is doubled (not timepoints obvi)
	% but should left or right go first?
	vw_ts_both=[vw_ts_l vw_ts_r];
	% get rid of odd extra 2 dimensions in .mgh file. Should be 17,734 high SNR vertices with this mask.
	vw_ts_both=reshape(vw_ts_both(1,:,1,:), 555, 17734);
	% bigass connectivity matrix, takes 5 seconds or so to calc
	ba_conmat=corrcoef(vw_ts_both);
	% for each scale
	for K=2:max(Krange)
	% load in partitions
		K_Folder = [ProjectFolder '/SingleParcel_1by1_kequal_' num2str(K) '/Sub_' num2str(subjs(s))];
		K_part_subj =[K_Folder '/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_1_alphaL10_vxInfo1_ard0_eta0/final_UV.mat'];
		subj_part=load(K_part_subj);
		% do not see automated subject-level soft-parcel -> hard-parcel script... can double-check with zc
		%%% convert to HP - V for vert x K
		subj_V=subj_part.V{1};
		% new column for HP label
		subj_V(:,3)=zeros(1,length(subj_V));
		for V=1:length(subj_V)
			% Supplement vertex loadings with HP value (max K loading)
			subj_V(V,3)=find(max(subj_v(V,:),subj_v(V,:)));
		end 
		group_part=(group_parts,K);	
		% make empty vectors for connectivity values
		winconvals=zeros(1,K);
		% use triangular numbers to calc. number of b/w network values in this K
		bwconvals=zeros(1,((K*(K+1))/2));
		% for each "network"
		for N=1:K
			% get index of which vertices are in this K
			Kind=find(subj_V(V,3),N);	
			% within connectivity, average correlation within 	
			mean(mean(ba_conmat(
			% for each external network (can I use negative iters to not be redundant here?)
			for b=1:length(bwconvals)
			% between connectivity
			end
		end
	end
end
% write out withins
save('/cbica/projects/pinesParcels/results/connectivities/within_individ.mat')
save('/cbica/projects/pinesParcels/results/connectivities/within_group.mat')
% write out betweens
save('/cbica/projects/pinesParcels/results/connectivities/between_individ.mat')
save('/cbica/projects/pinesParcels/results/connectivities/between_group.mat')
