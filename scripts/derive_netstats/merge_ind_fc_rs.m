%%% Merge all subject/scale-level FC matrices into one struct for further proc

% to become 2 to 30 when stuff finishes running someday
Krange=2:30;

subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');

% initialize structures to be filled
for i=2:max(Krange)
	ind_mats{i}=zeros(i,i,length(subjs));
	gro_mats{i}=zeros(i,i,length(subjs));
	bTS_indmats{i}=zeros(i,i,length(subjs));
end

% for participation coefs
pcoefpos=zeros(17734,max(Krange),length(subjs));
pcoefneg=zeros(17734,max(Krange),length(subjs));

% fill in with each subj, note K=1 is empty for each
for s=1:length(subjs)
	% load in data
	fp=['/cbica/projects/pinesParcels/data/CombinedData/' num2str(subjs(s)) '/fc_metrics_rs.mat']
	fcmets=load(fp);	
	pcfp=['/cbica/projects/pinesParcels/data/CombinedData/' num2str(subjs(s)) '/pc_metrics_rs.mat']
	pcmets=load(pcfp);
	% throw it in 
	for k=2:max(Krange)
		ind_mats{k}(:,:,s)=fcmets.subjmats(k).Khouse;
		gro_mats{k}(:,:,s)=fcmets.subjmats(k).GKhouse;
		bTS_indmats{k}(:,:,s)=fcmets.subjmats(k).K_bTS_house;

		% k-1 because these were saved as 1:29	
		pcoefpos(:,k,s)=[pcmets.subjpcs(:,k-1).partcoefpos];
		pcoefneg(:,k,s)=[pcmets.subjpcs(:,k-1).partcoefneg];
	end
end

% save the cell struct array frakenmatrices
save('/cbica/projects/pinesParcels/results/aggregated_data/ind_conmats_allscales_allsubjs_rs.mat','ind_mats');
save('/cbica/projects/pinesParcels/results/aggregated_data/gro_conmats_allscales_allsubjs_rs.mat','gro_mats');
save('/cbica/projects/pinesParcels/results/aggregated_data/bts_conmats_allscales_allsubjs_rs.mat','bTS_indmats');
% matlab needs this v7.3 for files bigger than 2gb
save('/cbica/projects/pinesParcels/results/aggregated_data/vwise_pospc_allscales_allsubjs_rs.mat','pcoefpos','-v7.3');
save('/cbica/projects/pinesParcels/results/aggregated_data/vwise_negpc_allscales_allsubjs_rs.mat','pcoefneg','-v7.3');
