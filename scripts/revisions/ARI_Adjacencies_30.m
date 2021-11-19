%%% set scale with K
K=30
%%% to find ARI between parcels derived from different subjects, across tasks + rest
% add path
addpath('/cbica/projects/pinesParcels/multiscale/scripts/revisions/');

% load subjects list
subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');

% grandparent filepaths
ProjectFolder = '/cbica/projects/pinesParcels/data/SingleParcellation';
ResultantFolder = [ProjectFolder '/SingleParcel_1by1_kequal_' num2str(K)];
% set output directory
outdir='/cbica/projects/pinesParcels/results/aggregated_data/';

% 693 x 693 adjacency matrix for each comparison. Diagonals to be removed, but upper and lower triangle are non-redundant
% initialize big vectors to record vals for each pairwise subj comparison
restEmoMat=zeros(693,693);
restNbackMat=zeros(693,693);
EmoNbackMat=zeros(693,693);

% loop over subjs
for s=1:length(subjs)
% print subject number
s
% convert subjID to string
ID_Str=num2str(subjs(s));
% rest parent filepath
parentFP_r = [ResultantFolder '/Sub_' ID_Str '/rest_only/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_1_alphaL10_vxInfo1_ard0_eta0'];
% load rest mat
mR=load([parentFP_r '/final_UV.mat']);	
% emoID parent filepath
parentFP_e = [ResultantFolder '/Sub_' ID_Str '/emoID_only/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_1_alphaL10_vxInfo1_ard0_eta0'];
% load emoID mat
mE=load([parentFP_e '/final_UV.mat']);
% nback parent filepath
parentFP_n = [ResultantFolder '/Sub_' ID_Str '/nback_only/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_1_alphaL10_vxInfo1_ard0_eta0'];
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

	% inner subject loop: load every OTHER subject and compare
	for i=1:length(subjs)
	ID_Stri=num2str(subjs(i));
	% rest parent filepath
	parentFP_ri = [ResultantFolder '/Sub_' ID_Stri '/rest_only/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_1_alphaL10_vxInfo1_ard0_eta0'];
	% load rest mat
	mRi=load([parentFP_ri '/final_UV.mat']);
	% emoID parent filepath
	parentFP_ei = [ResultantFolder '/Sub_' ID_Stri '/emoID_only/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_1_alphaL10_vxInfo1_ard0_eta0'];
	% load emoID mat
	mEi=load([parentFP_ei '/final_UV.mat']);
	% nback parent filepath
	parentFP_ni = [ResultantFolder '/Sub_' ID_Stri '/nback_only/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_1_alphaL10_vxInfo1_ard0_eta0'];
	% load nback mat
	mNi=load([parentFP_ni '/final_UV.mat']);
	% convert
	%%% rest
	initV_ri=[mRi.V{:}];
	% trim tiny values 
	initV_ri_Max = max(initV_ri);
	trimInd_ri = initV_ri ./ max(repmat(initV_ri_Max, size(initV_ri, 1), 1), eps) < 5e-2;
	initV_r(trimInd_r) = 0;
	sbj_AtlasLoading_NoMedialWall_ri = initV_ri;
	% add this to vec_fc file it is more efficient
	[~, sbj_AtlasLabel_NoMedialWall_ri] = max(sbj_AtlasLoading_NoMedialWall_ri, [], 2);

	%%% emoID
	initV_ei=[mEi.V{:}];
	% trim tiny values 
	initV_ei_Max = max(initV_ei);
	trimInd_ei = initV_ei ./ max(repmat(initV_ei_Max, size(initV_ei, 1), 1), eps) < 5e-2;
	initV_ei(trimInd_ei) = 0;
	sbj_AtlasLoading_NoMedialWall_ei = initV_ei;
	% add this to vec_fc file it is more efficient
	[~, sbj_AtlasLabel_NoMedialWall_ei] = max(sbj_AtlasLoading_NoMedialWall_ei, [], 2);

	%%% nBack
	initV_ni=[mNi.V{:}];
	% trim tiny values 
	initV_ni_Max = max(initV_ni);
	trimInd_ni = initV_ni ./ max(repmat(initV_ni_Max, size(initV_ni, 1), 1), eps) < 5e-2;
	initV_ni(trimInd_ni) = 0;
	sbj_AtlasLoading_NoMedialWall_ni = initV_ni;
	% add this to vec_fc file it is more efficient
	[~, sbj_AtlasLabel_NoMedialWall_ni] = max(sbj_AtlasLoading_NoMedialWall_ni, [], 2);

	% ari rest-emo
	restEmoMat(s,i)=rand_index(sbj_AtlasLabel_NoMedialWall_r,sbj_AtlasLabel_NoMedialWall_ei,'adjusted');
	% ari rest-nback
	restNbackMat(s,i)=rand_index(sbj_AtlasLabel_NoMedialWall_r,sbj_AtlasLabel_NoMedialWall_ni,'adjusted');
	% ari emo-nback
	EmoNbackMat(s,i)=rand_index(sbj_AtlasLabel_NoMedialWall_n,sbj_AtlasLabel_NoMedialWall_ei,'adjusted');
	end

end

% diagonal is within subject, off-diagonal is between subjects for each matrix

% save aggregated matrices
writetable(table(restEmoMat),strcat(outdir,'/BwSubj_restEmoARI_K',num2str(K),'.csv'));
writetable(table(restNbackMat),strcat(outdir,'/BwSubj_restNbackARI_K',num2str(K),'.csv'));
writetable(table(EmoNbackMat),strcat(outdir,'/BwSubj_EmoNbackARI_K',num2str(K),'.csv'));
