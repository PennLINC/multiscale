%vertex-wise age effects over subjects and scales
outdir = '/cbica/projects/pinesParcels/results/aggregated_data'

%%%% Updates on 7/13/20 and 9/1/20, 12/1

Krange=2:30;

subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');
subjsStr=num2str(subjs);
subjsCell={};
subjsCell(:,1)=cellstr(subjsStr);
subjsTable=table(subjsCell);
subjsTable.Properties.VariableNames={'bblid'};
% load in r-generated bblid, Age, Motion, Sex arrays
rStats=load('/cbica/projects/pinesParcels/results/EffectVecs/forMLpc.csv');
rStatsCell={};
rStatsCell(:,1)=cellstr(num2str(rStats(:,1)));
rStatsCell(:,2)=num2cell(rStats(:,2));
rStatsCell(:,3)=num2cell(rStats(:,3));
rStatsCell(:,4)=num2cell(rStats(:,4));
rStatsTable=cell2table(rStatsCell,'VariableNames',{'bblid','Age','Motion', 'Sex'});

% lol at the struggle to get strings to sit next to numbers
% needed non-Net data
nnet=join(subjsTable,rStatsTable);

% check
if subjs(1)~=str2num(char(nnet{1,1}))
disp('You messed up, fool. You lost bash ordering convention of subjects. You lost your way.')
else
end
% load in between
bwstruct=load('/cbica/projects/pinesParcels/results/aggregated_data/ind_vertices_bw_allscales.mat');

%7/13/20 - used subj at index 542 to confirm alignment of ids - same 1st 10 vert pcs at scale 1 as from individual folder (individual pc_metrics.mat)
Covs=table2array(nnet(:,2:4));

for K=Krange
	% initialize empty matrix for this scale: all vertices' b/w vals for all subjs + age sex motion
	covsNverts=zeros(693,17737);
	covsNverts(:,1:3)=Covs;
	K
	BwK=bwstruct.dfbw(:,K-1,:);
	for v=1:17734
		covsNverts(:,v+3)=BwK(v,:)';
	end
	writetable(array2table(covsNverts),strcat(outdir,'/Scale_',num2str(K),'_vertices_bw_allscales.csv'));
end
