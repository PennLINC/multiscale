

addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
vecsfp='/cbica/projects/pinesParcels/results/EffectVecs';
%vecs=dir([vecsfp '/*mSeg.csv']);
%uncomment to switch to meanSegreg
% _i is for individualized, added to look at individ. vs gro. partition effect differences
% _g for group partitions
vecs=dir([vecsfp '/BW_InterceptAt*']);
% first two are . and ..
sizevecs=size(vecs);
for i=1:sizevecs(1)
	% i + 1 because 1:29 files but 2:30 scales
	scale=i+1;
	% have to manually reconstruct the name bc bash stores as 10 first
	fn=['BW_InterceptAt' num2str(scale)];
	effCellStruct{i}=load([vecsfp '/' fn]);
end
% name
effectname='BW_InterceptAt'
PBP_effect_msOverlay_2View(effCellStruct,effectname);
