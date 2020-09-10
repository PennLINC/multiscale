
% set s (1 of 694)
s=328

addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
vecsfp='/cbica/projects/pinesParcels/results/EffectVecs';

all_verts=load([vecsfp '/rSlopes.mat']);
allverts=all_verts.rSlope;

all_slopes=load([vecsfp '/rInts.mat']);
allslopes=all_slopes.rInt;

VertVec=allslopes(s,:);
name=[ num2str(s) '_multiscale_slopes']
PBP_vertWiseEffect(VertVec,name);

