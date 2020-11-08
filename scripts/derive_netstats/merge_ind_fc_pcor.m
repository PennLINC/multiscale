%%% Merge all subject/scale-level FC matrices into one struct for further proc

% to become 2 to 30 when stuff finishes running someday
Krange=2:30;

subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');

% initialize structures to be filled
for i=2:max(Krange)
	bTSP_indmats{i}=zeros(i,i,length(subjs));
end

% fill in with each subj, note K=1 is empty for each
for s=1:length(subjs)
	s
	% load in data
	fp=['/cbica/projects/pinesParcels/data/CombinedData/' num2str(subjs(s)) '/fc_metrics_pcor.mat']
	fcmets=load(fp);	
	% throw it in 
	for k=2:max(Krange)
		bTSP_indmats{k}(:,:,s)=fcmets.subjmats(k).K_bTSP_house;
	end
end

% save the cell struct array frakenmatrices
save('/cbica/projects/pinesParcels/results/aggregated_data/ind_conmats_allscales_allsubjs_pcor.mat','bTSP_indmats');
