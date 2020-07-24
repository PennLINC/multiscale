
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
% needed non-PC data
npc=join(subjsTable,rStatsTable);

% check
if subjs(1)~=str2num(char(npc{1,1}))
disp('You messed up, fool. You lost bash ordering convention of subjects. You lost your way.')
else
end
% load in posPCmatrix
ppcstruct=load('/cbica/projects/pinesParcels/results/aggregated_data/vwise_pospc_allscales_allsubjs.mat');

% initialize empty matrix for age effects at each scale
PcAgeEff=zeros(17734,29);

% initialize empty matrix for average PC at each scale
PcAvg=cell(693,30);
%7/13/20 - used subj at index 542 to confirm alignment of ids - same 1st 10 vert pcs at scale 1 as from individual folder (individual pc_metrics.mat)
parPCmat=table2array(npc(:,2:4));

for K=Krange
	K
	pcoefK=ppcstruct.pcoefpos(:,K,:);
	% get average value for each subject;
	for v=1:17734
		parPCmat(:,4)=pcoefK(v,:)';
		[ageCor,p]=partialcorr(parPCmat,'Type','Spearman');
		% we want the 4th element (comes in table format depicted beneath)
		PcAgeEff(v,K-1)=ageCor(4);
	end
	%   Age|Motion|Sex|PC|
	%Age   
	%Motion
	%Sex
	%PC
end

% total 2-30 dif
PcAgeTotDif=PcAgeEff(:,29)-PcAgeEff(:,1);
% difference between 2 and 7
PcAgeCoarseDif=PcAgeEff(:,8)-PcAgeEff(:,1);
% dif b/w scales 8 and 17
PcAgeMidDif=PcAgeEff(:,18)-PcAgeEff(:,9);
% dif b/w scales 18 and 30 
PcAgeFineDif=PcAgeEff(:,29)-PcAgeEff(:,19);

% for a more stable estimate of aggregate change over scales
CoarsestAvg=mean(PcAgeEff(:,1:3),2);
FinestAvg=mean(PcAgeEff(:,27:29),2);
% Stabilized Dif
PcAgeStabilizedDif=FinestAvg-CoarsestAvg;


% write out ageCorChanges
fnT=['/cbica/projects/pinesParcels/results/EffectVecs/agePCspearTotChange.mat'];
fnC=['/cbica/projects/pinesParcels/results/EffectVecs/agePCspearCoarseChange.mat'];
fnM=['/cbica/projects/pinesParcels/results/EffectVecs/agePCspearMidChange.mat'];
fnF=['/cbica/projects/pinesParcels/results/EffectVecs/agePCspearFineChange.mat'];
fnST=['/cbica/projects/pinesParcels/results/EffectVecs/agePCspearStabTotChange.mat'];
save(fnT,'PcAgeTotDif');
save(fnC,'PcAgeCoarseDif');
save(fnM,'PcAgeMidDif');
save(fnF,'PcAgeFineDif');
save(fnST,'PcAgeStabilizedDif');
