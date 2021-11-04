%%% to find ARI between parcels derived from the same subject, across tasks + rest
% add path
addpath('/cbica/projects/pinesParcels/multiscale/scripts/revisions/');

% set scale (here, or in caller script)
K=2

% load subjects list
subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');

% grandparent filepaths
ProjectFolder = '/cbica/projects/pinesParcels/data/SingleParcellation';
ResultantFolder = [ProjectFolder '/SingleParcel_1by1_kequal_' num2str(K)];
% set output directory
outdir='/cbica/projects/pinesParcels/results/aggregated_data/';

% initialize big vectors to recor vals for each subj
restEmoVec=[];
restNbackVec=[];
EmoNbackVec=[];

% loop over subjs
for s=1:length(subjs)
% print subject number
s
% convert subjID to string
ID_Str=num2str(subjs(s));
% rest parent filepath
parentFP_r = [ResultantFolder '/Sub_' ID_Str '/rest_only/IndividualParcel_Final_sbj1_comp2_alphaS21_1_alphaL10_vxInfo1_ard0_eta0'];
% load rest mat
mR=load([parentFP_r '/final_UV.mat']);	
% emoID parent filepath
parentFP_e = [ResultantFolder '/Sub_' ID_Str '/emoID_only/IndividualParcel_Final_sbj1_comp2_alphaS21_1_alphaL10_vxInfo1_ard0_eta0'];
% load emoID mat
mE=load([parentFP_e '/final_UV.mat']);
% nback parent filepath
parentFP_n = [ResultantFolder '/Sub_' ID_Str '/nback_only/IndividualParcel_Final_sbj1_comp2_alphaS21_1_alphaL10_vxInfo1_ard0_eta0'];
% load nback mat
mN=load([parentFP_n '/final_UV.mat']);

%%%%%% convert soft parcels to hard parcels
%%% rest
initV_r=[mR.V{:}];
% trim tiny values 
initV_r_Max = max(initV_r);
trimInd_r = initV_r ./ max(repmat(initV_r_Max, size(initV_r, 1), 1), eps) < 5e-2;
initV_r(trimInd_r) = 0;
sbj_AtlasLoading_NoMedialWall_r = initV_r;
% add this to vec_fc file it is more efficient
[~, sbj_AtlasLabel_NoMedialWall_r] = max(sbj_AtlasLoading_NoMedialWall_r, [], 2);

%%% emoID
initV_e=[mE.V{:}];
% trim tiny values 
initV_e_Max = max(initV_e);
trimInd_e = initV_e ./ max(repmat(initV_e_Max, size(initV_e, 1), 1), eps) < 5e-2;
initV_e(trimInd_e) = 0;
sbj_AtlasLoading_NoMedialWall_e = initV_e;
% add this to vec_fc file it is more efficient
[~, sbj_AtlasLabel_NoMedialWall_e] = max(sbj_AtlasLoading_NoMedialWall_e, [], 2);

%%% nBack
initV_n=[mN.V{:}];
% trim tiny values 
initV_n_Max = max(initV_n);
trimInd_n = initV_n ./ max(repmat(initV_n_Max, size(initV_n, 1), 1), eps) < 5e-2;
initV_n(trimInd_n) = 0;
sbj_AtlasLoading_NoMedialWall_n = initV_n;
% add this to vec_fc file it is more efficient
[~, sbj_AtlasLabel_NoMedialWall_n] = max(sbj_AtlasLoading_NoMedialWall_n, [], 2);

% ari rest-emo
restEmoVec(s)=rand_index(sbj_AtlasLabel_NoMedialWall_r,sbj_AtlasLabel_NoMedialWall_e,'adjusted');
% ari rest-nback
restNbackVec(s)=rand_index(sbj_AtlasLabel_NoMedialWall_r,sbj_AtlasLabel_NoMedialWall_n,'adjusted');
% ari emo-nback
EmoNbackVec(s)=rand_index(sbj_AtlasLabel_NoMedialWall_n,sbj_AtlasLabel_NoMedialWall_e,'adjusted');
end

% save aggregated vectors
writetable(table(restEmoVec),strcat(outdir,'/winSubj_restEmoARI.csv'));
writetable(table(restNbackVec),strcat(outdir,'/winSubj_restNbackARI.csv'));
writetable(table(EmoNbackVec),strcat(outdir,'/winSubj_EmoNbackARI.csv'));
