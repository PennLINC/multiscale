

addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
vecsfp='/cbica/projects/pinesParcels/results/EffectVecs';
effectname='Avg_k'
vecs=dir([vecsfp '/Avg_k*']);
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
PBP_effect_msOverlay_2View_R_lPFC(effCellStruct,effectname);
%PBP_effect_msOverlay(effCellStruct,effectname);
