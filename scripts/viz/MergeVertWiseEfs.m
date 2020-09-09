% set effects dir
efdir='/gpfs/fs001/cbica/projects/pinesParcels/pmacstxr/mixedEffectModels/';
% initiate empty 17734 vectors
fSlope=zeros(17734,1);
fInt=zeros(17734,1);
rSlopeAge=zeros(17734,1);
rIntAge=zeros(17734,1);
fMotion=zeros(17734,1);

% loop over all vertices outside of SNR mask
for v=1:17734
v=v
% read csv
vfn=[efdir,'Modeled_fS_fI_raS_raI_fM_v',string(v),'_bwVals_overScales.csv'];
vfnjoined=join(vfn,'');
vtab=readtable(vfnjoined);
fSlope(v)=vtab.(1);
fInt(v)=vtab.(2);
rSlopeAge(v)=vtab.(3);
rIntAge(v)=vtab.(4);
fMotion(v)=vtab.(5);
end

save('/cbica/projects/pinesParcels/results/EffectVecs/fSlope.mat','fSlope');
save('/cbica/projects/pinesParcels/results/EffectVecs/fInt.mat','fInt');
save('/cbica/projects/pinesParcels/results/EffectVecs/rSlopeAge.mat','rSlopeAge');
save('/cbica/projects/pinesParcels/results/EffectVecs/rIntAge.mat','rIntAge');
save('/cbica/projects/pinesParcels/results/EffectVecs/fMotion.mat','fMotion');
