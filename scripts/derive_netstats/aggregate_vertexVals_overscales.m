%vertex-wise age effects over subjects and scales

%%%% Updates on 7/13/20, 9/1/20, and 1/24/21

% range of scales (K) to loop over
Krange=2:30;

% load in subjects
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

% check to make sure subjects aligned in same order w/ matlab-generated and r-generated vectors
if subjs(1)~=str2num(char(nnet{1,1}))
disp('You messed up, fool. You lost bash ordering convention of subjects. You lost your way.')
else
end

% load in between
bwstruct=load('/cbica/projects/pinesParcels/results/aggregated_data/ind_vertices_bw_allscales.mat');

%%%%%%%%%%%%%%%%%%%% 1/24/21 - aggregate values across scales for scale*subject matrices for each vertex *%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% need a dataframe of subjects over scales for one vertex at a time

for v=1:17734
	
	% just to track loop progress
	v=v
	
	% extract between values across scales for this vertex
	Vertices_bwvals=squeeze(bwstruct.dfbw(v,:,:));

	% slap on subject list to first column for matching in r
	Vertices_bwvals(30,:)=subjs;

	% transpose so subjects are rows (column will be subject ID)
	Vertices_bwvals=Vertices_bwvals.';

	fnV=strjoin(['/cbica/projects/pinesParcels/results/mixedEffectModels/v' string(v) '_bwVals_overScales.csv'],'');
	writetable(table(Vertices_bwvals),fnV);
end

