effect_vector_dir='/gpfs/fs001/cbica/projects/pinesParcels/results/EffectVecs/';
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
% for each scale
for K=20;
	K=K
	% read without headers and first column
	data=csvread([effect_vector_dir 'Scale' num2str(K) '_EFBw_VertDR2s.csv'],1,1);
        % read in MC-Q values
        Qs=csvread([effect_vector_dir 'Scale' num2str(K) '_EFBw_VertQs.csv'],1,1);
        % set DR2s where Q>0.05 to 0
        InSig=Qs > 0.05;
        data(InSig)=0;
	PBP_vertWiseEffect4View(data,['EFDR2_Scale' num2str(K)])
end
