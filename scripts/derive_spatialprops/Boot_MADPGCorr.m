% addpaths
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
% set outdir
outdir='/cbica/projects/pinesParcels/results/aggregated_data/';
% set paths
ProjectFolder = '/cbica/projects/pinesParcels/data/princ_gradients';
WorkingFolder = '/cbica/projects/pinesParcels/data/SingleParcellation/SingleAtlas_Analysis';

% get gradients
pgl = gifti([ProjectFolder '/Gradients.lh.fsaverage5.func.gii']);
pgr = gifti([ProjectFolder '/Gradients.rh.fsaverage5.func.gii']);
% extract unimodal-transmodal gradient
grad_lh = pgl.cdata(:,1);
grad_rh = pgr.cdata(:,1);
% load in mask (SNR Mask)
surfML = '/cbica/projects/pinesParcels/data/H_SNR_masks/lh.Mask_SNR.label';
mwIndVec_l = read_medial_wall_label(surfML);
Index_l = setdiff([1:10242], mwIndVec_l);
surfMR = '/cbica/projects/pinesParcels/data/H_SNR_masks/rh.Mask_SNR.label';
mwIndVec_r = read_medial_wall_label(surfMR);
Index_r = setdiff([1:10242], mwIndVec_r);
% convert into 17734 vector, masked out snr vertices
grad_lh=grad_lh(Index_l);
grad_rh=grad_rh(Index_r);
pg1=vertcat(grad_lh,grad_rh);
% read in bootstrapped subject indices
BootInd=csvread(['/cbica/projects/pinesParcels/results/BootIndices' num2str(v) '.csv']);
% initialize array for MAD*PG cors at each scale
MADPGCorr_acrossScales=zeros(1,29);
for K=2:30
	K
	LoadingFolder = [WorkingFolder '/FinalAtlasLoading_' num2str(K)];
	DataCell = g_ls([LoadingFolder '/*.mat']);
	% populate loading matrix according to bootstrap indices
	BootCell = DataCell(BootInd); 
	% add each set of loadings
	for i = 1:length(BootCell)
 		tmp = load(BootCell{i});
  		for j = 1:K
    			cmd = ['sbj_Loading_lh_Matrix_' num2str(j) '(i, :) = tmp.sbj_AtlasLoading_lh(j, :);'];
    			eval(cmd);
    			cmd = ['sbj_Loading_rh_Matrix_' num2str(j) '(i, :) = tmp.sbj_AtlasLoading_rh(j, :);'];
    			eval(cmd);
  		end
	end
	% calculate MAD across Bootstrap indicesll_lh = zeros(K, 10242);
	Variability_All_rh = zeros(K, 10242);
	for m = 1:K
  		for n = 1:10242
    			% left hemi
    			cmd = ['tmp_data = sbj_Loading_lh_Matrix_' num2str(m) '(:, n);'];
    			eval(cmd);
    			Variability_lh(n) = median(abs(tmp_data - median(tmp_data)));
    			eval(cmd);
    			% right hemi
    			cmd = ['tmp_data = sbj_Loading_rh_Matrix_' num2str(m) '(:, n);'];
    			eval(cmd);
    			Variability_rh(n) = median(abs(tmp_data - median(tmp_data)));
  		end
  		% aggregate network variability for this network at this scale into aggreg. var. for this scale.
		Variability_All_lh(m, :) = Variability_lh;
  		Variability_All_rh(m, :) = Variability_rh;
	end
	% K system mean (average across all Ks)
	VariabilityLoading_Median_KSystemMean_lh = mean(Variability_All_lh);
	VariabilityLoading_Median_KSystemMean_rh = mean(Variability_All_rh);
	MAD_K=horzcat(VariabilityLoading_Median_KSystemMean_lh(:, Index_l),VariabilityLoading_Median_KSystemMean_rh(:, Index_r));	
	% correlate with PG (spear)
	PGMADCorr_K=corr(MAD_K',pg1,'type','spearman','rows','complete');
	% K-1 because we start with scale 2
	MADPGCorr_acrossScales(K-1)=PGMADCorr_K;
end
% save out MADPGCorrs for this bootstrap resample
dlmwrite(['/cbica/projects/pinesParcels/results/Boot_MADPGCorr_acrossScales' num2str(v) '.csv'],MADPGCorr_acrossScales) 
