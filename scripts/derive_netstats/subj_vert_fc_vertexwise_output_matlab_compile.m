	
	% version adopted to be compiled into non-license using executable
	fc_configfp=varagin{1}
	passed_ml_args=load(fc_configfp);
	s=passed_ml_args.s;
	surfMask=passed_ml_args.surfMask;
	surfMaskl=surfMask.l;
	surfMaskr=surfMask.r;
	Krange=passed_ml_args.Krange;
	subjs=passed_ml_args.subjs;
	group_parts_masked=passed_ml_args.group_parts_masked;
	outdir_i=passed_ml_args.outdir_i;
	outdir_g=passed_ml_args.outdir_g;
	outdir_b=passed_ml_args.outdir_b;
	
	% version adapted to print out vertex-wise values for each subject for each scale (for within and b/w values)

	addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
	addpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_netstats/')

	% s is subject-specific iteration being parallelized
	% surfMask should be in format of 0=remove this vertex, low snr. 1 = keep this vertex, high snr
	% Krange is range of scales to calculate fc metrics over. in format of Kmin:Kmax
	% subjs needs to be accessed via subjs(s) later on
	% outdir should be for each subject across scales, as outfile will contain subj info across scales
	
	% Make empty vertex-level segregation metric coefficient vector (# vert in mask, ~=fsaverage5)
	% will make segregation vectors from output of this script
	ind_wincon_verts=zeros(17734,length(Krange));
	ind_bwcon_verts=zeros(17734,length(Krange));
	gro_wincon_verts=zeros(17734,length(Krange));
        gro_bwcon_verts=zeros(17734,length(Krange));	

	
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
			winconsum=sum(curNetMat);
			g_winconsum=sum(g_curNetMat);
			% subtract 1 for diagonals
			winconsum_min=winconsum-1;
			g_winconsum_min=g_winconsum-1;
			% convert to average
			wincon_avg=((winconsum_min)/(length(Kind)-1));
			g_wincon_avg=((g_winconsum_min)/(length(g_Kind)-1));
			% put it in df according to current K index (K-1 because K starts at 2, df starts at 1)
			ind_wincon_verts(Kind,K-1)=wincon_avg';
			gro_wincon_verts(g_Kind,K-1)=g_wincon_avg';
			% index vertices not in up-one-level-network-N loop
			NotKind=find(subj_V(:,K+1)~=N);
			g_NotKind=find(group_part~=N);
			% make matrix of this networks vertices correlations with non-member vertices
			bwMat=ba_conmat(Kind,NotKind);
			g_bwMat=ba_conmat(g_Kind,g_NotKind);
			% use "2" so it averages across current network's vertices
			bwcon=mean(bwMat,2);
			g_bwcon=mean(g_bwMat,2);
		
			ind_bwcon_verts(Kind,K-1)=bwcon';
			gro_bwcon_verts(g_Kind,K-1)=g_bwcon';
		end
		toc
	end
	% save files to subjdir
	subj_ind_segmetrics=struct('i_win',num2cell(ind_wincon_verts),'i_bw',num2cell(ind_bwcon_verts));
	subj_gro_segmetrics=struct('g_win',num2cell(gro_wincon_verts),'g_bw',num2cell(gro_bwcon_verts))
	save(outdir_i,'subj_ind_segmetrics')
	save(outdir_g,'subj_gro_segmetrics')
	% 2GB + file
	save(outdir_b,'ba_conmat', '-v7.3') 
	exit(1)
