
% get the tools
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
% load in hand-off network-level age effect derivative vectors from R
vecsfp='/cbica/projects/pinesParcels/results/EffectVecs';
% change between 10, 16, and 21 in the next two rows to run on various agepoints
vecs=dir([vecsfp '/Deriv16yoAt*']);
effectname='Deriv16yoAt'
% get size of vectors
sizevecs=size(vecs);
for i=1:sizevecs(1)
	% i + 1 because 1:29 files but 2:30 scales
	scale=i+1;
	% have to manually reconstruct the name bc bash stores files in its own order
	fn=[effectname num2str(scale)];
	% make a cell structure for matlab visualization function
	effCellStruct{i}=load([vecsfp '/' fn]);
end
% run matlab visualization function for network-level age effect derivatives averaged over scales
PBP_effect_msOverlay_2View_R_lPFC(effCellStruct,effectname);
