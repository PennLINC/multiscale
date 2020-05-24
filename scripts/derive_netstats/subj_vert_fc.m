function subj_vert_fc(s, surfMaskl, surfMaskr, Krange, subjs, group_parts_masked, outdir, outdirp)
	% s is subject-specific iteration being parallelized
	% surfMask should be in format of 0=remove this vertex, low snr. 1 = keep this vertex, high snr
	% Krange is range of scales to calculate fc metrics over. in format of Kmin:Kmax
	% subjs needs to be accessed via subjs(s) later on
	% outdir should be for each subject across scales, as outfile will contain subj info across scales
	%%% Make empty cell arrays with a spot for each metric at each scale
	for i=2:max(Krange)
        	Khouse{i}=zeros(i);
        	GKhouse{i}=zeros(i);
        	K_bTS_house{i}=zeros(i);
	end
	
	% Make empty vertex-level participation coefficient vector (# vert in mask, ~=fsaverage5)
	partcoefpos=zeros(17734,length(Krange));
	partcoefneg=zeros(17734,length(Krange));
		
        vw_ts_l_p=['/cbica/projects/pinesParcels/data/CombinedData/' num2str(subjs(s)) '/lh.fs5.sm6.residualised.mgh'];
	vw_ts_r_p=['/cbica/projects/pinesParcels/data/CombinedData/' num2str(subjs(s)) '/rh.fs5.sm6.residualised.mgh'];
	vw_ts_l=MRIread(vw_ts_l_p);
	vw_ts_r=MRIread(vw_ts_r_p);
	vw_ts_l=vw_ts_l.vol;
	vw_ts_r=vw_ts_r.vol;
	% apply SNR masks
	vw_ts_l_masked=vw_ts_l(1,(logical(surfMaskl)),1,:);
	vw_ts_r_masked=vw_ts_r(1,(logical(surfMaskr)),1,:);
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
		tic
		K	
		% 2D matrices
		Kmat=zeros(K);
                g_Kmat=zeros(K);
                bTS_Kmat=zeros(K);
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
			% mean correlation with each other network, other networks denoted by "b"
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
		% K-1 because K starts at 2, pcoef arrays starts at 1
		partcoefpos(:,K-1)=pospc;
		partcoefneg(:,K-1)=negpc;
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
		%%% save all FC, PC coef files in subj dir to be aggregated later
		Khouse{K}=Kmat;
                GKhouse{K}=g_Kmat;
                K_bTS_house{K}=bTS_Kmat;
		toc
	end
	% save files to subjdir
	subjmats=struct('Khouse',Khouse,'GKhouse',GKhouse,'K_bTS_house',K_bTS_house);
	subjpcs=struct('partcoefpos',num2cell(partcoefpos),'partcoefneg',num2cell(partcoefneg));
	save(outdir,'subjmats')
	save(outdirp,'subjpcs')
	 
