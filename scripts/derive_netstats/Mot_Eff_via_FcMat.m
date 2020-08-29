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
% load in r-generated bblid, EF, Motion, Sex arrays
rStats=load('/cbica/projects/pinesParcels/results/EffectVecs/forML_EF.csv');
rStatsCell={};
rStatsCell(:,1)=cellstr(num2str(rStats(:,1)));
rStatsCell(:,2)=num2cell(rStats(:,2));
rStatsCell(:,3)=num2cell(rStats(:,3));
rStatsCell(:,4)=num2cell(rStats(:,4));
rStatsCell(:,5)=num2cell(rStats(:,5));
rStatsTable=cell2table(rStatsCell,'VariableNames',{'bblid','EF','Age','Motion', 'Sex'});
% needed non-FC data
nfc=join(subjsTable,rStatsTable);
if subjs(1)~=str2num(char(nfc{1,1}))
disp('You messed up, fool. You lost bash ordering convention of subjects. You lost your way.')
else
end

% this is the table I will use iteratively (EF age sex motion are constant across fc values
% remove irrelevant EF column (column 2, irrel. for looking at this relation)
parFCmat=table2array(nfc(:,3:5));

% motion-only model for simplicity
parFCmat=table2array(nfc(:,4));

for K=Krange;
K       
        % extract fc mats at this scale
        fcmatscell=alldata.ind_mats(K);
        fcmats=fcmatscell{:};
        % create empty matrix of same size (but without a dimension for each subject) to house age effects
        sizeFc=size(fcmatscell{:});
        Mot_EfMat=zeros(sizeFc(1),sizeFc(2));
        % for each row
        for i=1:sizeFc(1);
                % for each spot
                for j=1:sizeFc(1);
                        % single element of fc matrices at this scale
			% changed from 4 to 2 to have only dual regression for motion-only model
                        parFCmat(:,2)=fcmats(i,j,:);
                        % partial spearmans
                        [Mot_Cor,p]=partialcorr(parFCmat,'Type','Spearman');
                        % changed from 4 to only cor value (because we are pairwise in simple version)
			Mot_EfMat(i,j)=Mot_Cor(2);
                end
        end
        fn=['/cbica/projects/pinesParcels/results/EffectMats/fc_Mot_Mat_K' num2str(K) '.csv'];
        writetable(table(Mot_EfMat),fn);
   
end
