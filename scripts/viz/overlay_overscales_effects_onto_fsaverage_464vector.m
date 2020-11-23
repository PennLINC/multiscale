

addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
vecsfp='/cbica/projects/pinesParcels/results/EffectVecs';
%vecs=dir([vecsfp '/*mSeg.csv']);
%uncomment to switch to meanSegreg
% _i is for individualized, added to look at individ. vs gro. partition effect differences
% _g for group partitions
vecs=load([vecsfp '/maxderiv']);
% first two are . and ..
for K=2:30
	K_start=((K-1)*(K))/2;
      	K_end=(((K-1)*(K))/2)+K-1;
      	Kind=K_start:K_end;
	% pick out this scale with Kind
	file=vecs(Kind);
	% transform them to represent age in years
	file=(((file*178)/200)+98)/12;
	effCellStruct{K-1}=file;
end
% name
effectname='MaxDeriv'
PBP_effect_msOverlay(effCellStruct,effectname);
