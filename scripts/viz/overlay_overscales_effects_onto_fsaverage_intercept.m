
% add toolbox path
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
vecsfp='/cbica/projects/pinesParcels/results/EffectVecs';
% add R-printout estimated b/w intercepts at each age - replace At10 with At21 if estimate at 21 desired
vecs=dir([vecsfp '/BW_InterceptAt10_k*']);
% first two are . and ..
sizevecs=size(vecs);
for i=1:29
	% i + 1 because 1:29 files but 2:30 scales
	scale=i+1;
	% have to manually reconstruct the name bc bash stores as 10 first - same not as above applies, replace 10 if desired
	fn=['BW_InterceptAt10_k' num2str(scale)];
	effCellStruct{i}=load([vecsfp '/' fn]);
end
% name of printed brainmap
effectname='Name'
PBP_effect_msOverlay_2View(effCellStruct,effectname);
