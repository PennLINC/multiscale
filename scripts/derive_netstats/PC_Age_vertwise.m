
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
npcstruct=load('/cbica/projects/pinesParcels/results/aggregated_data/vwise_negpc_allscales_allsubjs.mat');
% initialize empty matrix for age effects at each scale
PcAgeEff=zeros(17734,29);
NegPcAgeEff=zeros(17734,29);
% initialize empty matrix for average PC at each scale
PcAvg=cell(693,30);
NegPCAvg=cell(693,30);
% One column for bblid
PcAvg(:,1)=num2cell(subjs);
NegPCAvg(:,1)=num2cell(subjs);
% change it back to string for writing purposes
PcAvg(:,1)=cellstr(string(PcAvg(:,1)));
NegPcAvg(:,1)=cellstr(string(NegPCAvg(:,1)));
%7/13/20 - used subj at index 542 to confirm alignment of ids - same 1st 10 vert pcs at scale 1 as from individual folder (individual pc_metrics.mat)
parPCmat=table2array(npc(:,2:4));

for K=Krange
	K
	pcoefK=ppcstruct.pcoefpos(:,K,:);
	NegpcoefK=npcstruct.pcoefneg(:,K,:);
	% get average value for each subject;
	PcAvg(:,K)=num2cell(mean(pcoefK));
	NegPcAvg(:,K)=num2cell(mean(NegpcoefK));
	for v=1:17734
		parPCmat(:,4)=pcoefK(v,:)';
		[ageCor,p]=partialcorr(parPCmat,'Type','Spearman');
		% we want the 4th element (comes in table format depicted beneath)
		PcAgeEff(v,K-1)=ageCor(4);
		%%% and for negative values
		parPCmat(:,4)=NegpcoefK(v,:)';
                [ageCor,p]=partialcorr(parPCmat,'Type','Spearman');
		NegPcAgeEff(v,K-1)=ageCor(4);
		end
	%   Age|Motion|Sex|PC|
	%Age   
	%Motion
	%Sex
	%PC
end

% write out ageCors
fn=['/cbica/projects/pinesParcels/results/EffectVecs/agePCspear.mat'];
save(fn,'PcAgeEff');

fnAvgPC=['/cbica/projects/pinesParcels/results/EffectVecs/avgPC.csv'];
writetable(cell2table(PcAvg),fnAvgPC);

% repeat for negative PCs

fn=['/cbica/projects/pinesParcels/results/EffectVecs/ageNegPCspear.mat'];
save(fn,'NegPcAgeEff');

fnAvgPC=['/cbica/projects/pinesParcels/results/EffectVecs/avgNegPC.csv'];
writetable(cell2table(NegPcAvg),fnAvgPC);

%%%%%%%%%%%%%%%%%%%%%% A look at vertex-wise age-relation slope
% total 2-30 dif
PcAgeTotDif=PcAgeEff(:,29)-PcAgeEff(:,1);
NegPcAgeTotDif=NegPcAgeEff(:,29)-NegPcAgeEff(:,1);
% difference between 2 and 7
PcAgeCoarseDif=PcAgeEff(:,8)-PcAgeEff(:,1);
NegPcAgeCoarseDif=NegPcAgeEff(:,8)-NegPcAgeEff(:,1);
% dif b/w scales 8 and 17
PcAgeMidDif=PcAgeEff(:,18)-PcAgeEff(:,9);
NegPcAgeMidDif=NegPcAgeEff(:,18)-NegPcAgeEff(:,9);
% dif b/w scales 18 and 30 
PcAgeFineDif=PcAgeEff(:,29)-PcAgeEff(:,19);
NegPcAgeFineDif=NegPcAgeEff(:,29)-NegPcAgeEff(:,19);

% write out ageCorChanges
fnT=['/cbica/projects/pinesParcels/results/EffectVecs/agePCspearTotChange.mat'];
fnC=['/cbica/projects/pinesParcels/results/EffectVecs/agePCspearCoarseChange.mat'];
fnM=['/cbica/projects/pinesParcels/results/EffectVecs/agePCspearMidChange.mat'];
fnF=['/cbica/projects/pinesParcels/results/EffectVecs/agePCspearFineChange.mat'];
save(fnT,'PcAgeTotDif');
save(fnC,'PcAgeCoarseDif');
save(fnM,'PcAgeMidDif');
save(fnF,'PcAgeFineDif');

% and for negative
% write out ageCorChanges
fnT=['/cbica/projects/pinesParcels/results/EffectVecs/ageNegPCspearTotChange.mat'];
fnC=['/cbica/projects/pinesParcels/results/EffectVecs/ageNegPCspearCoarseChange.mat'];
fnM=['/cbica/projects/pinesParcels/results/EffectVecs/ageNegPCspearMidChange.mat'];
fnF=['/cbica/projects/pinesParcels/results/EffectVecs/ageNegPCspearFineChange.mat'];
save(fnT,'NegPcAgeTotDif');
save(fnC,'NegPcAgeCoarseDif');
save(fnM,'NegPcAgeMidDif');
save(fnF,'NegPcAgeFineDif');
