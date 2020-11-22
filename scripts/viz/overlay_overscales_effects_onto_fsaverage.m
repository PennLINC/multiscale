

addpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox');
vecsfp='/cbica/projects/pinesParcels/results/EffectVecs';
%vecs=dir([vecsfp '/*mSeg.csv']);
%uncomment to switch to meanSegreg
% _i is for individualized, added to look at individ. vs gro. partition effect differences
% _g for group partitions
vecs=dir([vecsfp '/*_EF_i.csv']);
% first two are . and ..
sizevecs=size(vecs);
for i=1:sizevecs(1)
	% Set to EF for this version. Change lines 3 and 5 if you switch this one. and the _Age.csv fn a few lines down
	%ffectname='mSeg'
	effectname='EF_i';
	% i + 1 because 1:29 files but 2:30 scales
	scale=i+1;
	% have to manually reconstruct the name bc bash stores as 10 first
	fn=[num2str(scale) '_' effectname '.csv'];
	effCellStruct{i}=load([vecsfp '/' fn]);
end
PBP_effect_msOverlay(effCellStruct,effectname);
