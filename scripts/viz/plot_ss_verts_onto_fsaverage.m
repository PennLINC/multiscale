
function plot_ss_verts_onto_fsaverage(s)
% s is subject according to mixed effect subject ordering (328 is 100031)
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
vecsfp='/cbica/projects/pinesParcels/results/EffectVecs';

all_verts=load([vecsfp '/rSlopes.mat']);
allvertsSlope=all_verts.rSlope;

all_verts=load([vecsfp '/rInts.mat']);
allvertsInt=all_verts.rInt;

% print intercepts
VertVec=allvertsInt(s,:);
name=[ num2str(s) '_multiscale_intercepts']
PBP_vertWiseEffect(VertVec,name);

% print slopes
VertVec=allvertsSlope(s,:);
name=[ num2str(s) '_multiscale_slopes']
PBP_vertWiseEffect(VertVec,name);
