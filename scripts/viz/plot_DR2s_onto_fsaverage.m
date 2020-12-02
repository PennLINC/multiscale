effect_vector_dir='/gpfs/fs001/cbica/projects/pinesParcels/results/EffectVecs/';
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
% for each scale
for K=2:30;
	K=K
	% read without headers and first column
	data=csvread([effect_vector_dir 'Scale' num2str(K) '_AgeBw_VertDR2s.csv'],1,1);
	PBP_vertWiseEffect(data,['AgeDR2_Scale' num2str(K)])
end
