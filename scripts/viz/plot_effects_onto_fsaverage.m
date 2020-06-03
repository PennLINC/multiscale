% set K
K=16;
% set effect size vector (corrected if needed)
effvec=[ -0.363 -0.160 0.307 -0.337 -0.246 -0.226 -0.382 0.254 0 -0.190 0 0 -0.262 0.232 -0.352 -0.184 ];

addpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox');
PBP_effect(K,effvec);
