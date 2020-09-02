% load in all fc matrices (individualized partitions)
alldata=load('/cbica/projects/pinesParcels/results/aggregated_data/ind_conmats_allscales_allsubjs.mat');
Krange=2:30;

% load in oldest and youngest ids
youngids=load('/cbica/projects/pinesParcels/results/aggregated_data/YoungestThirdIDs.csv');
oldids=load('/cbica/projects/pinesParcels/results/aggregated_data/OldestThirdIDs.csv');

% I guess this is how to get covariates together in matlab, there must be a more efficient way
subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');

% section to get index of where young and old ids are in matlab bblid order
[~,youngind]=intersect(subjs,youngids);
[~,oldind]=intersect(subjs,oldids);


% truncated Krange
Krange=[4, 7, 13, 20];

for K=Krange;
K
        % extract fc mats at this scale
        fcmatscell=alldata.ind_mats(K);
        fcmats=fcmatscell{:};
	fcmatsyoung=fcmats(:,:,youngind);
	fcmatsold=fcmats(:,:,oldind);


	% write average old and average young fc matrix at this scale
	avgOld=mean(fcmatsold,3);
	avgYoung=mean(fcmatsyoung,3);

        fn=['/cbica/projects/pinesParcels/results/EffectMats/fc_oldMat_K' num2str(K) '.csv'];
        writetable(table(avgOld),fn);

        fn=['/cbica/projects/pinesParcels/results/EffectMats/fc_youngMat_K' num2str(K) '.csv'];
        writetable(table(avgYoung),fn);
end

