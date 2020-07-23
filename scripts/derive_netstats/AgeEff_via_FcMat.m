% load in all fc matrices (individualized partitions)
alldata=load('/cbica/projects/pinesParcels/results/aggregated_data/ind_conmats_allscales_allsubjs.mat');
Krange=2:30;

% I guess this is how to get covariates together in matlab, there must be a more efficient way
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
% needed non-FC data
nfc=join(subjsTable,rStatsTable);
if subjs(1)~=str2num(char(nfc{1,1}))
disp('You messed up, fool. You lost bash ordering convention of subjects. You lost your way.')
else
end

% this is the table I will use iteratively (age sex motion are constant across fc values
parFCmat=table2array(nfc(:,2:4));

for K=Krange;
K       
        % extract fc mats at this scale
        fcmatscell=alldata.ind_mats(K);
        fcmats=fcmatscell{:};
        % create empty matrix of same size (but without a dimension for each subject) to house age effects
        sizeFc=size(fcmatscell{:});
        ageEfMat=zeros(sizeFc(1),sizeFc(2));
        % for each row
        for i=1:sizeFc(1);
                % for each spot
                for j=1:sizeFc(1);
                        % single element of fc matrices at this scale
                        parFCmat(:,4)=fcmats(i,j,:);
                        % partial spearmans
                        [ageCor,p]=partialcorr(parFCmat,'Type','Spearman');
                        ageEfMat(i,j)=ageCor(4);
                end
        end
        fn=['/cbica/projects/pinesParcels/results/EffectMats/fc_ageMat_K' num2str(K) '.csv'];
        writetable(table(ageEfMat),fn);
   
end
