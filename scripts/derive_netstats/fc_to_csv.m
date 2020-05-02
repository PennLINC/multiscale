outdir='/cbica/projects/pinesParcels/results/aggregated_data/fc/'

% to become 2 to 30 when stuff finishes running someday
Krange=2:3

subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');

% load in the cell struct array frakenmatrices
ind_file=load('/cbica/projects/pinesParcels/results/connectivities/ind_conmats_allscales_allsubjs.mat');
gro_file=load('/cbica/projects/pinesParcels/results/connectivities/gro_conmats_allscales_allsubjs.mat');	
bts_file=load('/cbica/projects/pinesParcels/results/connectivities/bts_conmats_allscales_allsubjs.mat');

% calculate dataframe size
win_over_scales=zeros((length(Krange)*((min(Krange)+max(Krange))/2)),1);
% same number of within FC features as network-wise segreg, one per each network per each K per each subject
Networkwise_seg_over_scales=FC_win_over_scales;
% global segregation is just one per each K for each subj
glob_seg_over_scales=zeros(length(Krange),1);
% but between network features are trickier, triangular number of K for each scale
bw_over_scales=[];
for K=Krange
	bw_overscales=[bw_overscales, zeros(1,(((K-1)*(K))/2)];
end
% get length of each, multiply by 3 for the 3 operationalizations of FC, and make an empty array of those combined +1 for subj ids

full_df_colnum=(3*(length(win_over_scales)+length(Networkwise_seg_over_scales)+length(glob_Seg_over_scales)+length(bw_over_scales)))+1;
df=zeros(length(subjs),full_df_colnum);
df(:,1)=subjs;

% make a colnames row with the 4 column types generated
colnames=strings(full_df_colnum+1);
colnames(1)='bblid';
% thirds names
thirdsnames=['ind' 'gro' 'bts'];
% lol quintiple nested for loops just to create an empty df
% for each third
for t=1:3;
	thirdname=thirdsnames(t);
	% for each FC feature type
	win_strings=strings(length(win_over_scales));
	seg_strings=strings(length(Networkwise_seg_over_scales));
	glob_seg_strings=strings(length(glob_seg_over_scales));
	bw_strings=strings(length(bw_over_scales));
		for f=2:(length(win_over_scales)+1)
			for K=Krange
				for N=1:length(K)
				win_strings(f)=strcat(thirdname, '_win_FC_scale' num2str(K), '_net' num2str(N));
				end
			end
		end
		for f=(length(win_over_scales)+2):(length(win_over_scales)+1+length(Networkwise_seg_over_scales))
			for K=Krange
                                for N=1:length(K)
                                seg_strings(f)=strcat(thirdname, '_seg_scale' num2str(K), '_net' num2str(N));
                                end
                        end
                end
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
		for f=(length(win_over_scales)+2+length(Networkwise_seg_over_scales)+length(glob_seg_over_scales):(length(win_over_scales)+1+length(Networkwise_seg_over_scales)+length(glob_seg_over_scales)+length(bw_over_scales)
			for K=Krange
                                glob_seg_strings(f)=strcat(thirdname, '_globseg_scale' num2str(K)));
                        end
                end

% make sure to feed in data in this order - global seg, network seg, within, b/w
colnames=[colnames, glob_segstrings, seg_strings, win_strings, bw_strings];
end

% make 
% maybe stack variable input in string creation? for s=1:length subjs in the deepest part of the 4 looping structures for each fc type
for K=Krange
	ind_feats=ind_file.Khouse;
	gro_feats=gro_file.GKhouse;
	bts_feats=bts_file.K_bTS_house;
	ind=ind_feats{K};
	gro=gro_feats{K};
	bts=bts_feats{K};
	
	ind_fc_win=ind(
	gro_fc_win=
	bts_fc_win=
	

	
	df(
