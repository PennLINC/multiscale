%iterate over subjects to get within and between network connectivities for each scale (K)

% add needed paths
addpath(genpath('/cbica/projects/pinesParcels/scripts/derive_parcels/Toolbox'));

ProjectFolder = '/cbica/projects/pinesParcels/data/SingleParcellation';

% What is K range to iterate over?
% I'll tell you hwhat
Krange=2:30;
% Read in subjects list
subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');
% read in group partitions
group_parts=load([ProjectFolder '/SingleAtlas_Analysis/group_all_Ks.mat']);
group_parts=group_parts.affils;
% load in SNR masks
l_l = read_label([],'/cbica/projects/pinesParcels/data/H_SNR_masks/lh.Mask_SNR.label');
l_r = read_label([],'/cbica/projects/pinesParcels/data/H_SNR_masks/rh.Mask_SNR.label');
% assuming +1 is because matlab starts on 1, not 0. can double-check with zc
l_l_ind = l_l(:,1) + 1;
l_r_ind = l_r(:,1) + 1;
% check to make sure that mask indices match 0s in group consensus to ensure consistent masking throughout
% NOTE THAT THIS MASK FILE INDICATES THE PRESENCE OF VERTICES TO BE MASKED, NOT IN 0 = BAD 1 = GOOD FORMAT
if sum(group_parts(l_l_ind))~=0
disp('you screwed up the left hemisphere mask numbnuts')
exit(1);
else
end
if sum(group_parts(10242+l_r_ind))~=0
disp('you screwed up the right hemisphere mask numbnuts')
exit(1);
else
end
% change mask from 0s from 1 at shitty vertices to 0
surfMask.l = ones(10242,1);
surfMask.l(l_l_ind) = 0;
surfMask.r = ones(10242,1);
surfMask.r(l_r_ind) = 0;
% same thing but with 
% mask group partitions by taking nonzeros (masked prior to NMF)
group_parts_masked=group_parts(any(group_parts,2),:);
% initialize 3d kmats and gkmats (summarized network to network connectivities and w/in connectivities, third dimension is subjs)
% -1 because we start at 2 (so the houses will go from 1-29 instead of 2-30)
for i=1:(max(Krange)-1)
	Khouse{i}=zeros(i,i,length(subjs));
	GKhouse{i}=zeros(i,i,length(subjs));
end
% for each subject
for s=1:length(subjs)
	% load in vertex-wise time series
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
	% but should left or right go first?
	vw_ts_both=[vw_ts_l_masked vw_ts_r_masked];
	% get rid of odd extra 2 dimensions in .mgh file. Should be 17,734 high SNR vertices with this mask.
	vw_ts_both=reshape(vw_ts_both(1,:,1,:), 555, 17734);
	% bigass connectivity matrix, takes 5 seconds or so to calc
	ba_conmat=corrcoef(vw_ts_both);
	% for each scale
	for K=2:max(Krange)
		% model the 3D matrix of interest (current K/scale) from the house of K's, to populate and shove back in later
		curGK=GKhouse{K};
		curK=Khouse{K};
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
			subj_V(V,3)=find(subj_V(V,:)==(max(subj_V(V,:))));
		end 
		% evaluate group consensus in parallel, k-1 because partitions start at 2
		group_part=group_parts_masked(:,K-1);	
		% make empty vectors for connectivity values
		winconvals=zeros(1,K);
		g_winconvals=zeros(1,K);
		% use triangular numbers (altered to K-1) to calc. number of b/w network values in this K
		bwconvals=zeros(1,(((K-1)*(K))/2));
		g_bwconvals=zeros(1,(((K-1)*(K))/2));
		% for each "network"
		for N=1:K
			% get index of which vertices are in this K
			Kind=find(subj_V(:,3)==N);
			% group
			g_Kind=find(group_part==N);	
			% extract matrix of just the current network
			curNetMat=ba_conmat(Kind,Kind);
			% group
			g_curNetMat=ba_conmat(g_Kind,g_Kind);
			% within connectivity, average correlation within, triu to avoid redundance in conmat 	
			wincon=mean(mean(triu(curNetMat,1)));
			g_wincon=mean(mean(triu(g_curNetMat,1)));
			winconvals(N)=wincon;
			g_winconvals(N)=g_wincon;

			% values are reasonable relative to each other (wincon > g_wincon), but lower than expected. Double check to make sure mapping on correctly
			% make vector for all values except for current K (N) to loop through
			Kvec=1:K;
			NotKvec=Kvec(Kvec~=N); 
			% mean correlation with each other network
			for b=1:(K-1)
				curOtherNet=NotKvec(b);
				NotKind=find(subj_V(:,3)==curOtherNet);
				g_NotKind=find(group_part==curOtherNet);
				bwMat=ba_conmat(Kind,NotKind);
				g_bwMat=ba_conmat(g_Kind,g_NotKind);
				bwcon=mean(mean(triu(bwMat,1)));
				g_bwcon=mean(mean(triu(g_bwMat,1)));
				bwconvals(b)=bwcon;
				g_bwconvals(b)=g_bwcon;
			end
		end
		% Make empty KxK matrix to summarize network connectivities
		Kmat=diag(winconvals);
		g_Kmat=diag(g_winconvals);
		% insert b/w net con into non-diagonals	
		IDmat=eye(K);
		nondiag=(1-IDmat);
		nondiagind=find(nondiag==1);
		Kmat(nondiagind)=[bwconvals bwconvals];
		g_Kmat(nondiagind)=[g_bwconvals g_bwconvals];
		curK(:,:,s)=Kmat;
		curGK(:,:,s)=g_Kmat;
		% shove back in so one more subject is filled out at this K
		Khouse{K}=curK;
		GKhouse{K}=curGK;
	end
end
% write out summary matrices
fn_ind=['/cbica/projects/pinesParcels/results/connectivities/ind_conmats_allscales_allsubjs.mat']
fn_gro=['/cbica/projects/pinesParcels/results/connectivities/gro_conmats_allscales_allsubjs.mat']	
save('Khouse',fn_ind)
save('GKhouse',fn_gro)
