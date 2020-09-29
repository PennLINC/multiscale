%vertex-wise age effects over subjects and scales

%%%% Updates on 7/13/20 and 9/1/20

Krange=2:30;

subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');
subjsStr=num2str(subjs);
subjsCell={};
subjsCell(:,1)=cellstr(subjsStr);
subjsTable=table(subjsCell);
subjsTable.Properties.VariableNames={'bblid'};
% load in r-generated bblid, EF, Age, Motion, Sex arrays
rStats=load('/cbica/projects/pinesParcels/results/EffectVecs/forML_EF.csv');
rStatsCell={};
rStatsCell(:,1)=cellstr(num2str(rStats(:,1)));
rStatsCell(:,2)=num2cell(rStats(:,2));
rStatsCell(:,3)=num2cell(rStats(:,3));
rStatsCell(:,4)=num2cell(rStats(:,4));
rStatsCell(:,5)=num2cell(rStats(:,5));
rStatsTable=cell2table(rStatsCell,'VariableNames',{'bblid','EF','Age','Motion', 'Sex'});

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
WinEF_Eff=zeros(17734,29);
BwEF_Eff=zeros(17734,29);

%7/13/20 - used subj at index 542 to confirm alignment of ids - same 1st 10 vert pcs at scale 1 as from individual folder (individual pc_metrics.mat)
parNetmat=table2array(nnet(:,2:5));

%%%%%%%%%%%%%%%%%%%% %9/1/20 - pulled out example vertices
% 9/8 - adapted to sample all vertices
% 9/14 - commented out for EF version
% need a dataframe of subjects over scales for one vertex at a time

% use vertex 40 for left motor, vertex 50 for left pfc,  vertexi 30 for vertex superior to left occipital pole

% Read in subjects list
% subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');

% for v=1:17734
	
	% just to track loop progress
%	v=v
	
	% extract between values across scales for this vertex
%	Vertices_bwvals=squeeze(bwstruct.dfbw(v,:,:));

	% slap on subject list to first column for matching in r
%	Vertices_bwvals(30,:)=subjs;

	% transpose so subjects are rows (column will be subject ID)
%	Vertices_bwvals=Vertices_bwvals.';

%	fnV=strjoin(['/cbica/projects/pinesParcels/results/mixedEffectModels/v' string(v) '_bwVals_overScales.csv'],'');
%	writetable(table(Vertices_bwvals),fnV);
%end

%%%%%%%%%%%%%%% End of vertices across subjects and scales sidecar



for K=Krange
	K
	WinK=winstruct.dfwin(:,K-1,:);
	BwK=bwstruct.dfbw(:,K-1,:);
	for v=1:17734
		parNetmat(:,5)=WinK(v,:)';
		[EFCor,p]=partialcorr(parNetmat,'Type','Spearman');
		% we want the 4th element (comes in table format depicted beneath)
		WinEF_Eff(v,K-1)=EFCor(5);
		%%% and for negative values
		parNetmat(:,5)=BwK(v,:)';
                [EFCor,p]=partialcorr(parNetmat,'Type','Spearman');
		BwEF_Eff(v,K-1)=EFCor(5);
		end
	%   Age|Motion|Sex|PC|
	%Age   
	%Motion
	%Sex
	%PC
end

% write out ageCors
fn=['/cbica/projects/pinesParcels/results/EffectVecs/EFwinspear.mat'];
save(fn,'WinEF_Eff');

% repeat for Bw

fn=['/cbica/projects/pinesParcels/results/EffectVecs/EFBwspear.mat'];
save(fn,'BwEF_Eff');



% Commented out for initial run of EF - 9/14/20
%%%%%%%%%%%%%%%%%%%%%% A look at vertex-wise age-relation slope
% total 2-30 dif
%WinAgeTotDif=WinAgeEff(:,29)-WinAgeEff(:,1);
%BwAgeTotDif=BwAgeEff(:,29)-BwAgeEff(:,1);
% difference between 2 and 7
%WinAgeCoarseDif=WinAgeEff(:,8)-WinAgeEff(:,1);
%BwAgeCoarseDif=BwAgeEff(:,8)-BwAgeEff(:,1);
% dif b/w scales 8 and 17
%WinAgeMidDif=WinAgeEff(:,18)-WinAgeEff(:,9);
%BwAgeMidDif=BwAgeEff(:,18)-BwAgeEff(:,9);
% dif b/w scales 18 and 30 
%WinAgeFineDif=WinAgeEff(:,29)-WinAgeEff(:,19);
%BwAgeFineDif=BwAgeEff(:,29)-BwAgeEff(:,19);

% actual correlations fit to each vertices' age relation over scales
%WinAgeEffScalesCor=zeros(17734,1);
%BwAgeEffScalesCor=zeros(17734,1);
%for v=1:17734
%	WinOverScales=WinAgeEff(v,:);
%	BwOverScales=BwAgeEff(v,:);
%	WinAgeEffScalesCor(v)=corr(WinOverScales',Krange');
%	BwAgeEffScalesCor(v)=corr(BwOverScales',Krange');
%end

% change above scale 7
%fineKrange=8:30;
%fWinAgeEffScalesCor=zeros(17734,1);
%fBwAgeEffScalesCor=zeros(17734,1);
%for v=1:17734
 %       WinOverScales=WinAgeEff(v,7:29);
  %      BwOverScales=BwAgeEff(v,7:29);
   %     fWinAgeEffScalesCor(v)=corr(WinOverScales',fineKrange');
    %    fBwAgeEffScalesCor(v)=corr(BwOverScales',fineKrange');
%end

% write out ageCorChanges
%fnT=['/cbica/projects/pinesParcels/results/EffectVecs/ageWinspearTotChange.mat'];
%fnC=['/cbica/projects/pinesParcels/results/EffectVecs/ageWinspearCoarseChange.mat'];
%fnM=['/cbica/projects/pinesParcels/results/EffectVecs/ageWinspearMidChange.mat'];
%fnF=['/cbica/projects/pinesParcels/results/EffectVecs/ageWinspearFineChange.mat'];
%save(fnT,'WinAgeTotDif');
%save(fnC,'WinAgeCoarseDif');
%save(fnM,'WinAgeMidDif');
%save(fnF,'WinAgeFineDif');

% and for between
% write out ageCorChanges
%fnT=['/cbica/projects/pinesParcels/results/EffectVecs/ageBwspearTotChange.mat'];
%fnC=['/cbica/projects/pinesParcels/results/EffectVecs/ageBwspearCoarseChange.mat'];
%fnM=['/cbica/projects/pinesParcels/results/EffectVecs/ageBwspearMidChange.mat'];
%fnF=['/cbica/projects/pinesParcels/results/EffectVecs/ageBwspearFineChange.mat'];
%save(fnT,'BwAgeTotDif');
%save(fnC,'BwAgeCoarseDif');
%save(fnM,'BwAgeMidDif');
%save(fnF,'BwAgeFineDif');

% write out correlation (slope) of vertexwise age correlations over scales
%fnW=['/cbica/projects/pinesParcels/results/EffectVecs/ageWinCor_x_ScaleCor.mat'];
%fnBW=['/cbica/projects/pinesParcels/results/EffectVecs/ageBwCor_x_ScaleCor.mat'];
%ffnW=['/cbica/projects/pinesParcels/results/EffectVecs/ageWinCor_x_ScaleCorFine.mat'];
%ffnBW=['/cbica/projects/pinesParcels/results/EffectVecs/ageBwCor_x_ScaleCorFine.mat'];
%save(fnW,'WinAgeEffScalesCor');
%save(fnBW,'BwAgeEffScalesCor');
%save(ffnW,'fWinAgeEffScalesCor');
%save(ffnBW,'fBwAgeEffScalesCor');