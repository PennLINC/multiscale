%iterate over subjects to get within and between network connectivities for each scale (K)

% add needed paths

ProjectFolder = '/cbica/projects/pinesParcels/data/SingleParcellation';

% What is K range to iterate over?
Krange=2:30
% Read in subjects list
subjs=load('/cbica/projects/pinesParcels/data/participants.txt')

% read in group partitions % TO DO - AUGMENT SCRIPT TO COMBINE ALL GROUP PARTS INTO A SINGLE .MAT
group_parts=load;
% for each subject
for s=1:length(subjs)
	% load in vertex-wise time series
	vw_ts_l_p=['/cbica/projects/pinesParcels/data/CombinedData/' subj 'lh.fs5.sm6.residualised.mgh']
	vw_ts_r_p=['/cbica/projects/pinesParcels/data/CombinedData/' subj 'rh.fs5.sm6.residualised.mgh']
	% bigass connectivity matrix
	% for each scale
	for K=2:max(Krange)
	% load in partitions
	K_Folder = [ProjectFolder '/SingleParcel_1by1_kequal_' num2str(K)];
	K_part_subj =[K_Folder '/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_1_alphaL10_vxInfo1_ard0_eta0/final_UV.mat'];
	subj_part=load(K_part_subj);
	group_part=(group_parts,K);	
	% make empty vectors for connectivity values
	winconvals=zeros(1,K);
	% use triangular numbers to calc. number of b/w network values in this K
	bwconvals=zeros(1,((K*(K+1))/2));
	% for each "network"
	for N=1:K
		% within connectivity, average correlation within 	
		% for each external network (can I use negative iters to not be redundant here?)
		for b=1:length(bwconvals)
		% between connectivity
		end
	end
end
% write out withins
save('/cbica/projects/pinesParcels/results/connectivities/within_individ.mat')
save('/cbica/projects/pinesParcels/results/connectivities/within_group.mat')
% write out betweens
save('/cbica/projects/pinesParcels/results/connectivities/between_individ.mat')
save('/cbica/projects/pinesParcels/results/connectivities/between_group.mat')
