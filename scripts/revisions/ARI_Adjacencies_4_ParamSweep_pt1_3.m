%%% set scale with K
K=4
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
%p5_5Mat=zeros(693,693);
%p5_10Mat=zeros(693,693);
p5_20Mat=zeros(693,693);
% o is just a placeholder bc matlab doesn't let me start a variable name with a number
%o1_5Mat=zeros(693,693);
%o1_20Mat=zeros(693,693);
%o2_5Mat=zeros(693,693);
%o2_10Mat=zeros(693,693);
%o2_20Mat=zeros(693,693);

% loop over subjs
for s=1:length(subjs)
% print subject number
s
% convert subjID to string
ID_Str=num2str(subjs(s));

% p5_5 FP
%p5_5FP = [ResultantFolder '/Sub_' ID_Str '/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_point5_redo_alphaL5_vxInfo1_ard0_eta0'];
%p5_5=load([p5_5FP '/IndividualParcel_Final_sbj1_comp20_alphaS21_point5_redo_alphaL5_vxInfo1_ard0_eta0/final_UV.mat']);
% convert to hard parcels
%initV=[p5_5.V{:}];
% trim tiny values 
%initV_Max = max(initV);
%trimInd = initV ./ max(repmat(initV_Max, size(initV, 1), 1), eps) < 5e-2;
%initV(trimInd) = 0;
%sbj_AtlasLoading_NoMedialWall = initV;
%[~, sbj_AtlasLabel_NoMedialWall_p5_5] = max(sbj_AtlasLoading_NoMedialWall, [], 2);

% p5_10 FP
%p5_10FP = [ResultantFolder '/Sub_' ID_Str '/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_point5_alphaLten_vxInfo1_ard0_eta0'];
%p5_10=load([p5_10FP '/IndividualParcel_Final_sbj1_comp20_alphaS21_1_alphaL10_vxInfo1_ard0_eta0/final_UV.mat']);
% convert to hard parcels
%initV=[p5_10.V{:}];
% trim tiny values 
%initV_Max = max(initV);
%trimInd = initV ./ max(repmat(initV_Max, size(initV, 1), 1), eps) < 5e-2;
%initV(trimInd) = 0;
%sbj_AtlasLoading_NoMedialWall = initV;
%[~, sbj_AtlasLabel_NoMedialWall_p5_10] = max(sbj_AtlasLoading_NoMedialWall, [], 2);

% p5_20 FP
p5_20FP = [ResultantFolder '/Sub_' ID_Str '/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_point5_redo_alphaL20_vxInfo1_ard0_eta0'];
p5_20=load([p5_20FP '/IndividualParcel_Final_sbj1_comp20_alphaS21_point5_redo_alphaL4_vxInfo1_ard0_eta0/final_UV.mat']);
% convert to hard parcels
initV=[p5_20.V{:}];
% trim tiny values 
initV_Max = max(initV);
trimInd = initV ./ max(repmat(initV_Max, size(initV, 1), 1), eps) < 5e-2;
initV(trimInd) = 0;
sbj_AtlasLoading_NoMedialWall = initV;
[~, sbj_AtlasLabel_NoMedialWall_p5_20] = max(sbj_AtlasLoading_NoMedialWall, [], 2);

% 1_5 FP
%o1_5FP = [ResultantFolder '/Sub_' ID_Str '/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_one_alphaLfive_vxInfo1_ard0_eta0'];
%o1_5=load([o1_5FP '/IndividualParcel_Final_sbj1_comp20_alphaS21_1_alphaL5_vxInfo1_ard0_eta0/final_UV.mat']);
% convert to hard parcels
%initV=[o1_5.V{:}];
% trim tiny values 
%initV_Max = max(initV);
%trimInd = initV ./ max(repmat(initV_Max, size(initV, 1), 1), eps) < 5e-2;
%initV(trimInd) = 0;
%sbj_AtlasLoading_NoMedialWall = initV;
%[~, sbj_AtlasLabel_NoMedialWall_1_5] = max(sbj_AtlasLoading_NoMedialWall, [], 2);

% 1_20 FP
%o1_20FP = [ResultantFolder '/Sub_' ID_Str '/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_one_alphaLtwenty_vxInfo1_ard0_eta0'];
%o1_20=load([o1_20FP '/IndividualParcel_Final_sbj1_comp20_alphaS21_1_alphaL20_vxInfo1_ard0_eta0/final_UV.mat']);
% convert to hard parcels
%initV=[o1_20.V{:}];
% trim tiny values 
%initV_Max = max(initV);
%trimInd = initV ./ max(repmat(initV_Max, size(initV, 1), 1), eps) < 5e-2;
%initV(trimInd) = 0;
%sbj_AtlasLoading_NoMedialWall = initV;
%[~, sbj_AtlasLabel_NoMedialWall_1_20] = max(sbj_AtlasLoading_NoMedialWall, [], 2);

% 2_5 FP
%o2_5FP = [ResultantFolder '/Sub_' ID_Str '/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_two_alphaLfive_vxInfo1_ard0_eta0'];
%o2_5=load([o2_5FP '/IndividualParcel_Final_sbj1_comp20_alphaS21_2_alphaL5_vxInfo1_ard0_eta0/final_UV.mat']);
% convert to hard parcels
%initV=[o2_5.V{:}];
% trim tiny values 
%initV_Max = max(initV);
%trimInd = initV ./ max(repmat(initV_Max, size(initV, 1), 1), eps) < 5e-2;
%initV(trimInd) = 0;
%sbj_AtlasLoading_NoMedialWall = initV;
%[~, sbj_AtlasLabel_NoMedialWall_2_5] = max(sbj_AtlasLoading_NoMedialWall, [], 2);

% 2_10 FP
%o2_10FP = [ResultantFolder '/Sub_' ID_Str '/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_two_alphaLten_vxInfo1_ard0_eta0'];
%o2_10=load([o2_10FP '/IndividualParcel_Final_sbj1_comp20_alphaS21_2_alphaL10_vxInfo1_ard0_eta0/final_UV.mat']);
% convert to hard parcels
%initV=[o2_10.V{:}];
% trim tiny values 
%initV_Max = max(initV);
%trimInd = initV ./ max(repmat(initV_Max, size(initV, 1), 1), eps) < 5e-2;
%initV(trimInd) = 0;
%sbj_AtlasLoading_NoMedialWall = initV;
%[~, sbj_AtlasLabel_NoMedialWall_2_10] = max(sbj_AtlasLoading_NoMedialWall, [], 2);

% 2_20 FP
%o2_20FP = [ResultantFolder '/Sub_' ID_Str '/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_two_alphaLtwenty_vxInfo1_ard0_eta0'];
%o2_20=load([o2_20FP '/IndividualParcel_Final_sbj1_comp20_alphaS21_2_alphaL20_vxInfo1_ard0_eta0/final_UV.mat']);
% convert to hard parcels
%initV=[o2_20.V{:}];
% trim tiny values 
%initV_Max = max(initV);
%trimInd = initV ./ max(repmat(initV_Max, size(initV, 1), 1), eps) < 5e-2;
%initV(trimInd) = 0;
%sbj_AtlasLoading_NoMedialWall = initV;
%[~, sbj_AtlasLabel_NoMedialWall_2_20] = max(sbj_AtlasLoading_NoMedialWall, [], 2);

% inner subject loop: load every OTHER subject and compare
for i=1:length(subjs)
	ID_Stri=num2str(subjs(i));
	% OG FP
	parentFP = [ResultantFolder '/Sub_' ID_Stri '/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_1_alphaL10_vxInfo1_ard0_eta0'];
	% load original .mat
	OG=load([parentFP '/final_UV.mat']);
	% convert to hard parcels
	initV=[OG.V{:}];
	% trim tiny values 
	initV_Max = max(initV);
	trimInd = initV ./ max(repmat(initV_Max, size(initV, 1), 1), eps) < 5e-2;
	initV(trimInd) = 0;
	sbj_AtlasLoading_NoMedialWall = initV;
	[~, sbj_AtlasLabel_NoMedialWall_OG] = max(sbj_AtlasLoading_NoMedialWall, [], 2);

	% get ARI
%	p5_5Mat(s,i)=rand_index(sbj_AtlasLabel_NoMedialWall_OG,sbj_AtlasLabel_NoMedialWall_p5_5,'adjusted');	
%	p5_10Mat(s,i)=rand_index(sbj_AtlasLabel_NoMedialWall_OG,sbj_AtlasLabel_NoMedialWall_p5_10,'adjusted');
	p5_20Mat(s,i)=rand_index(sbj_AtlasLabel_NoMedialWall_OG,sbj_AtlasLabel_NoMedialWall_p5_20,'adjusted');
%	o1_5Mat(s,i)=rand_index(sbj_AtlasLabel_NoMedialWall_OG,sbj_AtlasLabel_NoMedialWall_1_5,'adjusted');
%	o1_20Mat(s,i)=rand_index(sbj_AtlasLabel_NoMedialWall_OG,sbj_AtlasLabel_NoMedialWall_1_20,'adjusted');
%	o2_5Mat(s,i)=rand_index(sbj_AtlasLabel_NoMedialWall_OG,sbj_AtlasLabel_NoMedialWall_2_5,'adjusted');
%	o2_10Mat(s,i)=rand_index(sbj_AtlasLabel_NoMedialWall_OG,sbj_AtlasLabel_NoMedialWall_2_10,'adjusted');
%	o2_20Mat(s,i)=rand_index(sbj_AtlasLabel_NoMedialWall_OG,sbj_AtlasLabel_NoMedialWall_2_20,'adjusted');
end

end

% diagonal is within subject, off-diagonal is between subjects for each matrix

% save aggregated matrices
%writetable(table(p5_5Mat),strcat(outdir,'/BwSubj_p5_5_K',num2str(K),'_r.csv'));
%writetable(table(p5_10Mat),strcat(outdir,'/BwSubj_p5_10_K',num2str(K),'.csv'));
writetable(table(p5_20Mat),strcat(outdir,'/BwSubj_p5_20_K',num2str(K),'_r.csv'));
%writetable(table(o1_5Mat),strcat(outdir,'/BwSubj_1_5_K',num2str(K),'.csv'));
%writetable(table(o1_20Mat),strcat(outdir,'/BwSubj_1_20_K',num2str(K),'.csv'));
%writetable(table(o2_5Mat),strcat(outdir,'/BwSubj_2_5_K',num2str(K),'.csv'));
%writetable(table(o2_10Mat),strcat(outdir,'/BwSubj_2_10_K',num2str(K),'.csv'));
%writetable(table(o2_20Mat),strcat(outdir,'/BwSubj_2_20_K',num2str(K),'.csv'));

