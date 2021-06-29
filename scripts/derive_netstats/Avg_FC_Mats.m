% load in all fc matrices (individualized partitions)
alldata=load('/cbica/projects/pinesParcels/results/aggregated_data/ind_conmats_allscales_allsubjs.mat');
Krange=2:30;

for K=Krange;
K       
        % extract fc mats at this scale
        fcmatscell=alldata.ind_mats(K);
        fcmats=fcmatscell{:};
        % average FC matrices at this scale
	avgFCMat_atK=mean(fcmats,3);
        fn=['/cbica/projects/pinesParcels/results/EffectMats/fc_Mat_K' num2str(K) '.csv'];
        writetable(table(avgFCMat_atK),fn);
   
end
