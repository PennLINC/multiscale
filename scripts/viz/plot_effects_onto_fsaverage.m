

addpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox');
vecsfp='/cbica/projects/pinesParcels/results/EffectVecs';
vecs=dir([vecsfp '/*mSeg.csv']);
%uncomment to switch to EF
%vecs=dir([vecsfp '/*_EF.csv']);
% first two are . and ..
sizevecs=size(vecs);
for i=1:sizevecs(1)
	% Set to AGE for this version. Change lines 3 and 5 if you switch this one. and the _Age.csv fn a few lines down
	effectname='mSeg'
	%effectname='EF'
	% i + 1 because 1:29 files but 2:30 scales
	scale=i+1;
	% have to manually reconstruct the name bc bash stores as 10 first
	fn=[num2str(scale) '_' effectname '.csv'];
	effvec=load([vecsfp '/' fn]);
	PBP_effect(scale,effvec,effectname);
end
