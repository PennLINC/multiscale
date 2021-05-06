% addpaths
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
% set outdir
outdir='/cbica/projects/pinesParcels/results/aggregated_data/';
% set paths
ProjectFolder = '/cbica/projects/pinesParcels/data/princ_gradients';
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

% initialize permutation house for correlations for 1000 spins across scales, +1 row for real correlation
permHouse=zeros(1001,29);
% for each scale, get disitribution of spatial correlations with PG1
for K=2:30
	disp(K)
	% get MAD to test
	MADFile = ['/gpfs/fs001/cbica/projects/pinesParcels/data/SingleParcellation/SingleAtlas_Analysis/Variability_Visualize/VariabilityLoading_Median_' num2str(K) 'SystemMean.mat'];
	initmat=load(MADFile);
	MAD_atK=initmat.VariabilityLoading_Median_KSystemMean_NoMedialWall;
	%% get real correlation
	realrho=corr(MAD_atK',pg1,'type','spearman','rows','complete');
	permHouse(1,(K-1))=realrho;
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%% get permuted correlations
	permutFile=strcat('/cbica/projects/pinesParcels/results/aggregated_data/PGPermuts.mat');
	permuts=load(permutFile);
	permutsL=permuts.bigrotl(:,Index_l);
	permutsR=permuts.bigrotr(:,Index_r);	
	% change 100 (markers of invalid vertices) to NA
	permutsL(permutsL==100)=NaN;
	permutsR(permutsR==100)=NaN;
	% for each permutation
	for P=1:1000
		permutVals=[permutsL(P,:) permutsR(P,:)];
		permrho=corr(permutVals',MAD_atK','type','spearman', 'rows','complete');
		permHouse(1+P,(K-1))=permrho;
	end
end
% write out distribution, R friendly format
writetable(array2table(permHouse),strcat(outdir,'SpinTestDistrs_MAD_PG1.csv'),'Delimiter',',','QuoteStrings',true);
