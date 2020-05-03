outdir='/cbica/projects/pinesParcels/results/aggregated_data/fc/'

% to become 2 to 30 when stuff finishes running someday
Krange=2:3

subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');

% load in the cell struct array frakenmatrices
ind_file=load('/cbica/projects/pinesParcels/results/connectivities/ind_conmats_allscales_allsubjs.mat');
gro_file=load('/cbica/projects/pinesParcels/results/connectivities/gro_conmats_allscales_allsubjs.mat');	
bts_file=load('/cbica/projects/pinesParcels/results/connectivities/bts_conmats_allscales_allsubjs.mat');
ind_feats=ind_file.Khouse;
gro_feats=gro_file.GKhouse;
bts_feats=bts_file.K_bTS_house;

% calculate dataframe size
win_over_scales=zeros((length(Krange)*((min(Krange)+max(Krange))/2)),1);
% same number of within FC features as network-wise segreg, one per each network per each K per each subject
Networkwise_seg_over_scales=win_over_scales;
% global segregation is just one per each K for each subj
glob_seg_over_scales=zeros(length(Krange),1);
% but between network features are trickier, triangular number of K for each scale
bw_over_scales=[];
for K=Krange
	bw_over_scales=[bw_over_scales, zeros(1,(((K-1)*(K))/2))];
end
% get length of each, multiply by 3 for the 3 operationalizations of FC, and make an empty array of those combined +1 for subj ids

full_df_colnum=(3*(length(win_over_scales)+length(Networkwise_seg_over_scales)+length(glob_seg_over_scales)+length(bw_over_scales)))+1;
% length(subjs) +1 so theres a row for colnames
% looks like we can expect 16,357 columns for this dataframe if Krange=2:30
df=zeros((length(subjs)+1),full_df_colnum);
rownames=strings(length(subjs)+1,1);
rownames(1)='subjects' ;
rownames(2:(length(subjs)+1))=num2str(subjs);
df(:,1)=rownames;

% make a colnames row with the 4 column types generated
colnames=strings(full_df_colnum+1);
colnames(1)='bblid';
% thirds names
thirdsnames=["ind", "gro", "bts"];
% lol quintiple nested for loops just to create an empty df
% for each third
for t=1:3;
	thirdname=thirdsnames(t);
	pertinent_feat_name=strjoin([thirdname '_feats'],'');
	feats=eval([pertinent_feat_name]);
	
	%%% for each FC feature type %%%

	%% starting with WITHIN %%

	win_strings=strings(length(win_over_scales),1);
	% make index of where features for each scale belong in string
	Kind_w={};
	% make a df just for within network connectivities: creating different DFs for each type of FC feature to make this whole script more modular in order to help with troubleshooting
	df_win=zeros(length(subjs)+1,length(win_over_scales));
	% make an index of which places in feature vec align with which scale
	for K=Krange
		K_start=((K-1)*(K))/2;
		K_end=(((K-1)*(K))/2)+K-1;
		Kind_w{K}=K_start:K_end;
	end
	for K=Krange
		Kind=Kind_w{K};
		for N=1:K
			curindex=Kind(N);
			win_strings(curindex)=strcat(thirdname, '_win_FC_scale', num2str(K), '_net', num2str(N));
		end
		df_win(1,Kind)=win_strings;
		% extract matrices from this scale
		featurematrix=feats{K};
		for s=1:length(subjs);
			subjmat=featurematrix(:,:,s)
			subjwin=diag(subjmat);
			% s+1 because 1st row is colnames
			df_win(s+1,Kind)=subjwin;
		end
	end
		
	%% NW-WISE SEG %%

	seg_strings=strings(length(Networkwise_seg_over_scales),1);
	% can recycle indices here, netseg indices should be the same as within network (1 per network per scale)
	df_ns=zers(length(subjs)+1,length(Networkwise_seg_over_scales));	
	for K=Krange
		% recycled indices
		Kind=Kind_w{K};
		for N=1:K
			curindex=Kind(N);
			seg_strings(curindex)=strcat(thurdname,'_seg_scale', num2str(K), '_net', num2str(N));
		end
		df_ns(1,Kind)=seg_strings;
		%extract matrices from this scale
		featurematrix=feats{K};
		for s=1:length(subjs);
			subjmat=featurematrix(:,:,s);
			segvec=zeros(length(K);
			% calc segreg for each network
			for N=1:K
				Nrow=submat(N,:);
				winval=Nrow(N);
				NotcurNet=setdiff(1:K,N);
				bwvals=Nrow(NotcurNet);
				winz=atanh(winval);
				bwz=mean(atanh(bwvals));
				seg=(winz-bwz)/winz;
				segvec(N)=seg;
			end
			df_ns(s+1,Kind)=segvec;
		end
	end


% combine FC feature-type dfs for this third

% below this line is garbage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	glob_seg_strings=strings(length(glob_seg_over_scales),1);
	for f=(length(win_over_scales)+2+length(Networkwise_seg_over_scales):(length(win_over_scales)+1+length(Networkwise_seg_over_scales)+length(glob_seg_over_scales)
			for K=Krange
                                for N=1:length(K)
					curnet=N;
					netvec=1:length(K);
					Notcurnet=netvec(netvec~=N);
					for b=Notcurnet;
                                		bw_strings(f)=strcat(thirdname, '_bw_scale' num2str(K), '_net' num2str(N) 'and_' num2str(b));
                                end
                        end
                end

	bw_strings=strings(length(bw_over_scales),1);
		for f=(length(win_over_scales)+2+length(Networkwise_seg_over_scales)+length(glob_seg_over_scales):(length(win_over_scales)+1+length(Networkwise_seg_over_scales)+length(glob_seg_over_scales)+length(bw_over_scales)
			for K=Krange
                                glob_seg_strings(f)=strcat(thirdname, '_globseg_scale' num2str(K)));
                        end
                end

% make sure to feed in data in this order - global seg, network seg, within, b/w
colnames=[colnames, glob_segstrings, seg_strings, win_strings, bw_strings];
end
df(1,:)=colnames;

% make 
% maybe stack variable input in string creation? for s=1:length subjs in the deepest part of the 4 looping structures for each fc type
% decided not to - alignment of values in both loops should be baked-in double check
for K=Krange
	ind_feats=ind_file.Khouse;
	gro_feats=gro_file.GKhouse;
	bts_feats=bts_file.K_bTS_house;
	ind=ind_feats{K};
	gro=gro_feats{K};
	bts=bts_feats{K};

	% get index of df fields corresponding to this K
	
	for s=1:length(subjs)
		s_ind=ind(:,:,s);
		s_gro=gro(:,:,s);
		s_bts=bts(:,:,s);
		
		ind_win=diag(s_ind);
		gro_win=diag(s_gro);
		s_bts=diag(s_bts);
		
		% has to be in same order as super-nested loop upstairs
		in_bw=
		gro_bw=
		bts_bw=

		% zscore like gw lab for seg
		ind_nw_seg=
		gro_nw_seg=
		bts_nw_seg=

		% get average
		ind_g_seg=
		gro_g_seg=
		bts_g_seg=
	end
	% some kind of index of fields corresponding to this scale (K)
	df(Kind_ind)=
	df(Kind_gro)=
	df(Kind_bts)=
end
	
