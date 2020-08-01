% extract individual vertex-wise measures for a simple vertex-wise group-level average
datadir= '/cbica/projects/pinesParcels/data/CombinedData/'
% outdir
outdir = '/cbica/projects/pinesParcels/results/aggregated_data'
% Read in subjects list
subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');
% what would this script be without extra dimensionality
Krange=2:30;
% initialize empty dfs to average over
dfwin=zeros(17734,length(Krange),length(subjs));
dfbw=zeros(17734,length(Krange),length(subjs));
dfseg=zeros(17734,length(Krange),length(subjs));
% load in individual subjs
for s=1:length(subjs);
	s
	fp=[datadir num2str(subjs(s)) '/vertexwise_ind_fc_metrics.mat'];
	metrics=load(fp);
	metrics=metrics.subj_ind_segmetrics;
	% Gotta loop over dem scales
	for K=Krange
		% there's some dumb shit in here to deal with matlab struct arrays anti-array behavior
		% K-1 because scales start at 2 but struct starts at 1
		curKstruct=metrics(:,K-1);
		% for each vertex (AKA the dumb shit)
		for i=1:length(curKstruct);
			dfwin(i,K-1,s)=curKstruct(i).i_win;
			dfbw(i,K-1,s)=curKstruct(i).i_bw;
			% z-scored segreg
			dfseg(i,K-1,s)=((atanh(curKstruct(i).i_win))-(atanh(curKstruct(i).i_bw)))/(atanh(curKstruct(i).i_win));
		end
	end
end
% Take Averages 
dfwin_avg=mean(dfwin,3);
dfbw_avg=mean(dfbw,3);
dfseg_avg=mean(dfseg,3);
% save mean for viz format
fn=[outdir '/ind_vertices_mwin_allscales.mat'];
save(fn, 'dfwin_avg');
fn=[outdir '/ind_vertices_mbw_allscales.mat'];
save(fn, 'dfbw_avg');
fn=[outdir '/ind_vertices_mseg_allscales.mat'];
save(fn,'dfseg_avg');
% save for age relations eval
fn=[outdir '/ind_vertices_win_allscales.mat'];
save(fn,'dfwin','-v7.3');
fn=[outdir '/ind_vertices_bw_allscales.mat'];
save(fn, 'dfbw','-v7.3');
fn=[outdir '/ind_vertices_seg_allscales.mat'];
save(fn, 'dfseg','-v7.3');
% save for r friendly format (not needed atm, commented out)
%writetable(cell2table(dfwin),strcat(outdir,'/vertices_win_allscales.csv'));
%writetable(cell2table(dfbw),strcat(outdir,'/vertices_bw_allscales.csv'));
%writetable(cell2table(dfseg),strcat(outdir,'/vertices_seg_allscales.csv'));

%%%%%%%%% Group-parcel derived equivalent
% load in individual subjs
for s=1:length(subjs);
        s
	fp=[datadir num2str(subjs(s)) '/vertexwise_gro_fc_metrics.mat'];
        metrics=load(fp);
        metrics=metrics.subj_gro_segmetrics;
        % Gotta loop over dem scales
        for K=Krange
                % there's some dumb shit in here to deal with matlab struct arrays anti-array behavior
                % K-1 because scales start at 2 but struct starts at 1
                curKstruct=metrics(:,K-1);
                % for each vertex (AKA the dumb shit)
                for i=1:length(curKstruct);
                        dfwin(i,K-1,s)=curKstruct(i).g_win;
                        dfbw(i,K-1,s)=curKstruct(i).g_bw;
                        % z-scored segreg
                        dfseg(i,K-1,s)=((atanh(curKstruct(i).g_win))-(atanh(curKstruct(i).g_bw)))/(atanh(curKstruct(i).g_win));
                end
        end
end
% Take Averages 
dfwin_avg=mean(dfwin,3);
dfbw_avg=mean(dfbw,3);
dfseg_avg=mean(dfseg,3);
% save mean for viz format
fn=[outdir '/gro_vertices_mwin_allscales.mat'];
save(fn, 'dfwin_avg');
fn=[outdir '/gro_vertices_mbw_allscales.mat'];
save(fn, 'dfbw_avg');
fn=[outdir '/gro_vertices_mseg_allscales.mat'];
save(fn, 'dfseg_avg');
% save for age relations eval
fn=[outdir '/gro_vertices_win_allscales.mat'];
save(fn, 'dfwin','-v7.3');
fn=[outdir '/gro_vertices_bw_allscales.mat'];
save(fn, 'dfbw','-v7.3');
fn=[outdir '/gro_vertices_seg_allscales.mat'];
save(fn, 'dfseg','-v7.3');
