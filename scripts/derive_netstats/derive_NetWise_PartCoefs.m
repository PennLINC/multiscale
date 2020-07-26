
% extract acerage PC value for each subject for each scale for each network, derive 464 (num nets) by 693 (num subjs) matrix
Krange=2:30;

subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');
ProjectFolder = '/cbica/projects/pinesParcels/data/SingleParcellation';

% load in posPCmatrix
ppcstruct=load('/cbica/projects/pinesParcels/results/aggregated_data/vwise_pospc_allscales_allsubjs.mat');

% initialize empty matrix for each network PC value for each subject (extra column for bblid)
dataframe=zeros(693,464);

% for each subj
for s=1:length(subjs);
	s
	% initialize vector for 464 network PC values
	subjVector=subjs(s);
	% extract subjects' pcs
	subjspcs=ppcstruct.pcoefpos(:,:,s);
	% for each scale
	for K=Krange;
		% extract subjects' partitions for this scale
		K_Folder = [ProjectFolder '/SingleParcel_1by1_kequal_' num2str(K) '/Sub_' num2str(subjs(s))];
		K_part_subj =[K_Folder '/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_1_alphaL10_vxInfo1_ard0_eta0/final_UV.mat'];
		subj_part=load(K_part_subj);
		%%% convert to HP - V for vert x K
		subj_V=subj_part.V{1};
		% new column for HP label, K+1 because there should be K loading columns, so the last column becomes labels
		subj_V(:,K+1)=zeros(1,length(subj_V));
		[ ~ , subj_V(:,K+1)]=max(subj_V,[],2); 	
		% extract pcs for this scale
		subjpcsK=subjspcs(:,K);
		% for each net
		for N=1:K;
			% get vertices belonging to net N
			Kind=find(subj_V(:,K+1)==N);
			% get avg pc of these vertices (at this scale)
			meanPC=mean(subjpcsK(Kind));
			% append vector of scaleK_netN_PC
			subjVector=[subjVector meanPC];
		end
	end
	dataframe(s,:)=subjVector;
end
% print out average network-wise PC for sanity check
avgNwisePCs=mean(dataframe);
% write it out
writetable(table(dataframe),'/cbica/projects/pinesParcels/results/aggregated_data/NetworkWisePCVals.csv');
writetable(table(avgNwisePCs),'/cbica/projects/pinesParcels/results/aggregated_data/MeanNetworkWisePCVals.csv'); 
