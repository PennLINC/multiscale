% set effects dir
efdir='/gpfs/fs001/cbica/projects/pinesParcels/pmacstxr/mixedEffectModels/';
% initiate empty 17734 vectors
ageCoef=zeros(17734,1);
logScaleCoef=zeros(17734,1);
ageScaleIntCoef=zeros(17734,1);
motionCoef=zeros(17734,1);
sexCoef=zeros(17734,1);

% initiate subject-level measures
rSlope=zeros(693,17734);
rInt=zeros(693,17734);

% loop over all vertices outside of SNR mask
for v=1:17734
v=v
% read csv
vfn=[efdir,'Modeled_fAge_flSc_fMot_fSex_fMot_v',string(v),'_bwVals_overScales.csv'];
vfnjoined=join(vfn,'');
vtab=readtable(vfnjoined);
ageCoef(v)=vtab.(1);
logScaleCoef(v)=vtab.(2);
ageScaleIntCoef(v)=vtab.(3);
motionCoef(v)=vtab.(4);
sexCoef(v)=vtab.(5);

%subject level measures
%slvfn=['/gpfs/fs001/cbica/projects/pinesParcels/results/mixedEffectModels/subj_level_Modeled_fS_fI_raS_raI_fM_v',string(v),'_bwVals_overScales.csv'];
%slvfnjoined=join(slvfn,'');
%slvtab=readtable(slvfnjoined);
%rSlope(:,v)=slvtab{:,3};
%rInt(:,v)=slvtab{:,2};
end

% saved to original model parameters
save('/cbica/projects/pinesParcels/results/EffectVecs/ageCoef.mat','ageCoef');
save('/cbica/projects/pinesParcels/results/EffectVecs/logScaleCoef.mat','logScaleCoef');
save('/cbica/projects/pinesParcels/results/EffectVecs/agelogScaleIntCoef.mat','ageScaleIntCoef');
save('/cbica/projects/pinesParcels/results/EffectVecs/motionCoef.mat','motionCoef');
save('/cbica/projects/pinesParcels/results/EffectVecs/sexCoef.mat','sexCoef');

%save('/cbica/projects/pinesParcels/results/EffectVecs/rSlopes.mat','rSlope');
%save('/cbica/projects/pinesParcels/results/EffectVecs/rInts.mat','rInt');

% subj order used for random slope vertex mapping
%subjorder=slvtab{:,1};
%save('/cbica/projects/pinesParcels/results/EffectVecs/SubjOrder_InVert_rEffects.mat','subjorder');
