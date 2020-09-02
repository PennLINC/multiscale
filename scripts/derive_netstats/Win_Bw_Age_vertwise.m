%vertex-wise age effects over subjects and scales

%%%% Updates on 7/13/20 and 9/1/20

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
% load in within network values
winstruct=load('/cbica/projects/pinesParcels/results/aggregated_data/ind_vertices_win_allscales.mat');
% load in between
bwstruct=load('/cbica/projects/pinesParcels/results/aggregated_data/ind_vertices_bw_allscales.mat');
% initialize empty matrix for age effects at each scale
WinAgeEff=zeros(17734,29);
BwAgeEff=zeros(17734,29);

%7/13/20 - used subj at index 542 to confirm alignment of ids - same 1st 10 vert pcs at scale 1 as from individual folder (individual pc_metrics.mat)
parNetmat=table2array(nnet(:,2:4));

%%%%%%%%%%%%%%%%%%%% %9/1/20 - pulled out example vertices
% need a dataframe of subjects over scales for one vertex at a time

% use vertex 40 for left motor, vertex 50 for left pfc,  vertexi 30 for vertex superior to left occipital pole

% Read in subjects list
subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');

SVIS_v=squeeze(bwstruct.dfbw(30,:,:));
LMOT_v=squeeze(bwstruct.dfbw(40,:,:));
LPFC_v=squeeze(bwstruct.dfbw(50,:,:));

% slap on subject list to first column for matching in r
SVIS_v(30,:)=subjs;
LMOT_v(30,:)=subjs;
LPFC_v(30,:)=subjs;

% transpose so subjects are rows (column will be subject ID)
SVIS_vt=SVIS_v.';
LMOT_vt=LMOT_v.';
LPFC_vt=LPFC_v.';

fnVis=['/cbica/projects/pinesParcels/results/exampleVertVisbw.csv'];
fnMot=['/cbica/projects/pinesParcels/results/exampleVertMotbw.csv'];
fnPFC=['/cbica/projects/pinesParcels/results/exampleVertPFCbw.csv'];
writetable(table(SVIS_vt),fnVis);
writetable(table(LMOT_vt),fnMot);
writetable(table(LPFC_vt),fnPFC);

%%%%%%%%%%%%%%% End of example vertices across subjects and scales sidecar



for K=Krange
	K
	WinK=winstruct.dfwin(:,K-1,:);
	BwK=bwstruct.dfbw(:,K-1,:);
	for v=1:17734
		parNetmat(:,4)=WinK(v,:)';
		[ageCor,p]=partialcorr(parNetmat,'Type','Spearman');
		% we want the 4th element (comes in table format depicted beneath)
		WinAgeEff(v,K-1)=ageCor(4);
		%%% and for negative values
		parNetmat(:,4)=BwK(v,:)';
                [ageCor,p]=partialcorr(parNetmat,'Type','Spearman');
		BwAgeEff(v,K-1)=ageCor(4);
		end
	%   Age|Motion|Sex|PC|
	%Age   
	%Motion
	%Sex
	%PC
end

% write out ageCors
fn=['/cbica/projects/pinesParcels/results/EffectVecs/ageWinspear.mat'];
save(fn,'WinAgeEff');

% repeat for Bw

fn=['/cbica/projects/pinesParcels/results/EffectVecs/ageBwspear.mat'];
save(fn,'BwAgeEff');

%%%%%%%%%%%%%%%%%%%%%% A look at vertex-wise age-relation slope
% total 2-30 dif
WinAgeTotDif=WinAgeEff(:,29)-WinAgeEff(:,1);
BwAgeTotDif=BwAgeEff(:,29)-BwAgeEff(:,1);
% difference between 2 and 7
WinAgeCoarseDif=WinAgeEff(:,8)-WinAgeEff(:,1);
BwAgeCoarseDif=BwAgeEff(:,8)-BwAgeEff(:,1);
% dif b/w scales 8 and 17
WinAgeMidDif=WinAgeEff(:,18)-WinAgeEff(:,9);
BwAgeMidDif=BwAgeEff(:,18)-BwAgeEff(:,9);
% dif b/w scales 18 and 30 
WinAgeFineDif=WinAgeEff(:,29)-WinAgeEff(:,19);
BwAgeFineDif=BwAgeEff(:,29)-BwAgeEff(:,19);

% actual correlations fit to each vertices' age relation over scales
WinAgeEffScalesCor=zeros(17734,1);
BwAgeEffScalesCor=zeros(17734,1);
for v=1:17734
	WinOverScales=WinAgeEff(v,:);
	BwOverScales=BwAgeEff(v,:);
	WinAgeEffScalesCor(v)=corr(WinOverScales',Krange');
	BwAgeEffScalesCor(v)=corr(BwOverScales',Krange');
end

% change above scale 7
fineKrange=8:30;
fWinAgeEffScalesCor=zeros(17734,1);
fBwAgeEffScalesCor=zeros(17734,1);
for v=1:17734
        WinOverScales=WinAgeEff(v,7:29);
        BwOverScales=BwAgeEff(v,7:29);
        fWinAgeEffScalesCor(v)=corr(WinOverScales',fineKrange');
        fBwAgeEffScalesCor(v)=corr(BwOverScales',fineKrange');
end

% write out ageCorChanges
fnT=['/cbica/projects/pinesParcels/results/EffectVecs/ageWinspearTotChange.mat'];
fnC=['/cbica/projects/pinesParcels/results/EffectVecs/ageWinspearCoarseChange.mat'];
fnM=['/cbica/projects/pinesParcels/results/EffectVecs/ageWinspearMidChange.mat'];
fnF=['/cbica/projects/pinesParcels/results/EffectVecs/ageWinspearFineChange.mat'];
save(fnT,'WinAgeTotDif');
save(fnC,'WinAgeCoarseDif');
save(fnM,'WinAgeMidDif');
save(fnF,'WinAgeFineDif');

% and for between
% write out ageCorChanges
fnT=['/cbica/projects/pinesParcels/results/EffectVecs/ageBwspearTotChange.mat'];
fnC=['/cbica/projects/pinesParcels/results/EffectVecs/ageBwspearCoarseChange.mat'];
fnM=['/cbica/projects/pinesParcels/results/EffectVecs/ageBwspearMidChange.mat'];
fnF=['/cbica/projects/pinesParcels/results/EffectVecs/ageBwspearFineChange.mat'];
save(fnT,'BwAgeTotDif');
save(fnC,'BwAgeCoarseDif');
save(fnM,'BwAgeMidDif');
save(fnF,'BwAgeFineDif');

% write out correlation (slope) of vertexwise age correlations over scales
fnW=['/cbica/projects/pinesParcels/results/EffectVecs/ageWinCor_x_ScaleCor.mat'];
fnBW=['/cbica/projects/pinesParcels/results/EffectVecs/ageBwCor_x_ScaleCor.mat'];
ffnW=['/cbica/projects/pinesParcels/results/EffectVecs/ageWinCor_x_ScaleCorFine.mat'];
ffnBW=['/cbica/projects/pinesParcels/results/EffectVecs/ageBwCor_x_ScaleCorFine.mat'];
save(fnW,'WinAgeEffScalesCor');
save(fnBW,'BwAgeEffScalesCor');
save(ffnW,'fWinAgeEffScalesCor');
save(ffnBW,'fBwAgeEffScalesCor');
