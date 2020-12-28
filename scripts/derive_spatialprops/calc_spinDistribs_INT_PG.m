% addpaths
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
% set outdir
outdir='/cbica/projects/pinesParcels/results/aggregated_data/';
% set paths
ProjectFolder = '/cbica/projects/pinesParcels/data/princ_gradients';
% get gradient map
pgl = gifti([ProjectFolder '/Gradients.lh.fsaverage5.func.gii']);
pgr = gifti([ProjectFolder '/Gradients.rh.fsaverage5.func.gii']);
grad_lh = pgl.cdata(:,1);
grad_rh = pgr.cdata(:,1);
pg1=[grad_lh' grad_rh'];
% initialize permutation house for correlations for 1000 spins, +1 row for real correlation
permHouse=zeros(1001,1);
% get disitribution of spatial correlations with PG1
% get Avg Intercepts (from community-level modeling)
IntFile=['/cbica/projects/pinesParcels/results/AvgIntercept'];
Intstruct=load(IntFile);
int_lh=Intstruct.datalr(1:10242);
int_rh=Intstruct.datalr(10243:20484);
%%% get real correlation
% load in mask (SNR Mask)
surfML = '/cbica/projects/pinesParcels/data/H_SNR_masks/lh.Mask_SNR.label';
mwIndVec_l = read_medial_wall_label(surfML);
Index_l = setdiff([1:10242], mwIndVec_l);
surfMR = '/cbica/projects/pinesParcels/data/H_SNR_masks/rh.Mask_SNR.label';
mwIndVec_r = read_medial_wall_label(surfMR);
Index_r = setdiff([1:10242], mwIndVec_r);
int_lh(mwIndVec_l)=NaN;
int_rh(mwIndVec_r)=NaN;
int_merged=[int_lh int_rh];	
%% get real correlation
realrho=corr(int_merged',pg1','type','spearman','rows','complete');
permHouse(1,1)=realrho;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%%% get permuted correlations
permutFile=strcat(outdir,'IntPermuts.mat');
permuts=load(permutFile);
permutsL=permuts.bigrotl;
permutsR=permuts.bigrotr;	
% change 100 (markers of invalid vertices) to NA
permutsL(permutsL==100)=NaN;
permutsR(permutsR==100)=NaN;
% for each permutation
for P=1:1000
	permutVals=[permutsL(P,:) permutsR(P,:)];
	permrho=corr(permutVals',pg1','type','spearman', 'rows','complete');
	permHouse(1+P,1)=permrho;
end
% write out distribution, R friendly format
writetable(array2table(permHouse),strcat(outdir,'SpinTestDistrs_Int_PG1.csv'),'Delimiter',',','QuoteStrings',true);
