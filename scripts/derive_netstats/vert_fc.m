%iterate over subjects to get within and between network connectivities for each scale (K)

% add needed paths
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));

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

% bTS is basis time series - comparing correlation with K bases (U) to vertex-wise FC
% group consensus U exlcuded because it uses a concatenated time series, will disprop. match the subjs used to create it, and it's not clear why we'd expect it to align throughout task/rest
for i=2:max(Krange)
	Khouse{i}=zeros(i,i,length(subjs));
	GKhouse{i}=zeros(i,i,length(subjs));
	K_bTS_house{i}=zeros(i,i,length(subjs));
end
% participation coef. will be same vector length regardless of scale
partcoefpos=zeros(10242,length(subjs),length(Krange));
partcoefneg=zeros(10242,length(subjs),length(Krange));

% for each subject
for s=1:length(subjs)
	s
	tic
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
	vw_ts_both=[vw_ts_l_masked vw_ts_r_masked];
	% get rid of odd extra 2 dimensions in .mgh file. Should be 17,734 high SNR vertices with this mask.
	%vw_ts_both=reshape(vw_ts_both(1,:,1,:), 555, 17734);
	% reworking to see if reshape is an issue
	vw_ts_bothrw=zeros(555,17734);
	for x=1:length(vw_ts_bothrw)
		vw_ts_bothrw(:,x)=vw_ts_both(1,x,1,:);
	end
	% bigass connectivity matrix, takes 5 seconds or so to calc
	ba_conmat=corrcoef(vw_ts_bothrw);
	% for each scale
	for K=2:max(Krange)
		K
		% model the 3D matrix of interest (current K/scale) from the house of K's, to populate and shove back in later
		curGK=GKhouse{K};
		curK=Khouse{K};
		curbtsK=K_bTS_house{K};
		% 2D matrices
		Kmat=zeros(K);
                g_Kmat=zeros(K);
                bTS_Kmat=zeros(K);
		% load in partitions
		K_Folder = [ProjectFolder '/SingleParcel_1by1_kequal_' num2str(K) '/Sub_' num2str(subjs(s))];
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
		% make empty vectors for connectivity values
		winconvals=zeros(1,K);
		g_winconvals=zeros(1,K);
		bTS_winconvals=zeros(1,K);
		% use triangular numbers (altered to K-1) to calc. number of b/w network values in this K
		%bwconvals=zeros(1,(((K-1)*(K))/2));
		%g_bwconvals=zeros(1,(((K-1)*(K))/2));
		%bTS_bwconvals=zeros(1,(((K-1)*(K))/2));
		% get U at this scale to evaluate connectivities via correlation with K basis time series (U), but labeling as yu because it looks less like V
		subj_yu=subj_part.U{1};
		% for each "network"
		for N=1:K
			% get index of which vertices are in this K
			Kind=find(subj_V(:,K+1)==N);
			% group
			g_Kind=find(group_part==N);	
			% extract matrix of just the current network
			curNetMat=ba_conmat(Kind,Kind);
			% group
			g_curNetMat=ba_conmat(g_Kind,g_Kind);
			% within connectivity, average correlation within, triu to avoid redundance in conmat 	
			wincon=mean(curNetMat(find(~triu(ones(size(curNetMat))))));
			g_wincon=mean(g_curNetMat(find(~triu(ones(size(g_curNetMat))))));
			%winconvals(N)=wincon;
			%g_winconvals(N)=g_wincon;
			% and within connectivity assessed via cor. w/ U corresponding to same K
			K_TimeSeries=vw_ts_bothrw(:,Kind);	
			bTS_wincon=mean(corr(K_TimeSeries,subj_yu(:,N)));
			%bTS_winconvals(N)=bTS_wincon;
			% values are reasonable relative to each other (wincon > g_wincon), but lower than expected. Double check to make sure mapping on correctly
			% make vector for all values except for current K (N) to loop through
			Kvec=1:K;
			NotKvec=Kvec(Kvec~=N); 
			% mean correlation with each other network
			for b=1:(K-1)
				curOtherNet=NotKvec(b);
				% index vertices not in up-one-level-network-N loop
				NotKind=find(subj_V(:,K+1)==curOtherNet);
				g_NotKind=find(group_part==curOtherNet);
				bwMat=ba_conmat(Kind,NotKind);
				g_bwMat=ba_conmat(g_Kind,g_NotKind);
				bwcon=mean(mean(bwMat));
				g_bwcon=mean(mean(g_bwMat));
				bTScon=mean(corr(K_TimeSeries,subj_yu(:,curOtherNet)));
				
				Kmat(N,curOtherNet)=bwcon;
				g_Kmat(N,curOtherNet)=g_bwcon;
				bTS_Kmat(N,curOtherNet)=bTScon;
			end
			Kmat(N,N)=wincon;
			g_Kmat(N,N)=g_wincon;
			bTS_Kmat(N,N)=bTS_wincon;
		end
		% small section to get vertex-wise participation coefficients for this this subject at this scale
		[pospc, negpc] = participation_coef_sign(ba_conmat,subj_V(:,K+1));
		% K-1 because K starts at 2, 3d array starts at 1
		partcoefpos(:,s,K-1)=pospc;
		partcoefneg(:,s,K-1)=negpc;
		% Make empty KxK matrix to summarize network connectivities
		%Kmat=diag(winconvals);
		%g_Kmat=diag(g_winconvals);
		%bTS_Kmat=diag(bTS_winconvals);
		% insert b/w net con into non-diagonals	
		%IDmat=eye(K);
		%nondiag=(1-IDmat);
		%nondiagind=find(nondiag==1);
		%Kmat(nondiagind)=[bwconvals bwconvals];
		%g_Kmat(nondiagind)=[g_bwconvals g_bwconvals];
		%bTS_Kmat(nondiagind)=[bTS_bwconvals bTS_bwconvals];	
		curK(:,:,s)=Kmat;
		curGK(:,:,s)=g_Kmat;
		curbtsK(:,:,s)=bTS_Kmat;
		% shove back in so one more subject is filled out at this K
		Khouse{K}=curK;
		GKhouse{K}=curGK;
		K_bTS_house{K}=curbtsK;
		toc
	end
end
% write out summary matrices
fn_ind=['/cbica/projects/pinesParcels/results/connectivities/ind_conmats_allscales_allsubjs.mat'];
fn_gro=['/cbica/projects/pinesParcels/results/connectivities/gro_conmats_allscales_allsubjs.mat'];	
fn_bts=['/cbica/projects/pinesParcels/results/connectivities/bts_conmats_allscales_allsubjs.mat']; 
fn_pospcs=['/cbica/projects/pinesParcels/results/connectivities/pospcs_allscales_allsubjs.mat'];
fn_negpcs=['/cbica/projects/pinesParcels/results/connectivities/negpcs_allscales_allsubjs.mat'];
save('Khouse',fn_ind)
save('GKhouse',fn_gro)
save('K_bTS_house',fn_bts)
save('partcoefpos',fn_pospcs)
save('partcoefneg',fn_negpcs)
