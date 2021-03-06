% load in all fc matrices (group partitions)
alldata=load('/cbica/projects/pinesParcels/results/aggregated_data/gro_conmats_allscales_allsubjs.mat');
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
parFCmat=table2array(nfc(:,2:5));

for K=Krange;
K       
        % extract fc mats at this scale
        fcmatscell=alldata.gro_mats(K);
        fcmats=fcmatscell{:};
        % create empty matrix of same size (but without a dimension for each subject) to house age effects
        sizeFc=size(fcmatscell{:});
        EF_EfMat=zeros(sizeFc(1),sizeFc(2));
        % for each row
        for i=1:sizeFc(1);
                % for each spot
                for j=1:sizeFc(1);
                        % single element of fc matrices at this scale
                        parFCmat(:,5)=fcmats(i,j,:);
                        % partial spearmans
                        [EF_Cor,p]=partialcorr(parFCmat,'Type','Spearman');
                        EF_EfMat(i,j)=EF_Cor(5);
                end
        end
        fn=['/cbica/projects/pinesParcels/results/EffectMats/fc_EF_Mat_K' num2str(K) '_Gro.csv'];
        writetable(table(EF_EfMat),fn);
   
end
