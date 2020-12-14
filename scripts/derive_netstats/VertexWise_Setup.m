%vertex-wise age effects over subjects and scales

% your output directory
outdir = '/cbica/projects/pinesParcels/results/aggregated_data'

% load in surface-associated subjects list to ensure that they are in the same order as they are in your R file!
subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');
%%%% you can use these few lines to confirm ordering, or do it your own way
subjsStr=num2str(subjs);
subjsCell={};
% takes some massaging to get it in proper format
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
% join the tables together (will join on bblid, similar to merge in R)
nonFCdata=join(subjsTable,rStatsTable);
% check if 1st subject on matlab list is the same as the first subject on the merged list to ensure correspondence
if subjs(1)~=str2num(char(nnet{1,1}))
disp('Matlab subject list differs from merged subject list')
else
end
%%%% End of ordering confirmation

% load in surface values
surfaceValues=load('/cbica/projects/pinesParcels/results/aggregated_data/ind_vertices_bw_allscales.mat');
% initialize array to save out for R (FC values + Age Motion Sex, columns 2:4)
Covariates=table2array(nnet(:,2:4));
% initialize empty matrix for writeout all vertices (17734) + covariates of interest (3) for all subjects (693)
covsNverts=zeros(693,17737);
% this puts the 1st three columns as your covariates, important for the next step in R
covsNverts(:,1:3)=Covs;
% this is specific to the surface files I had for each subject, you might have to adapt it depending on what your surface data looks like
for v=1:17734
	% v+3 because the first three columns are covariates. The ' is there to transpose: remove if you data does not need to be transposed
	covsNverts(:,v+3)=surfaceValues(v,:)';
end
writetable(array2table(covsNverts),strcat(outdir,'/','SurfaceAndCovariates.csv'));
