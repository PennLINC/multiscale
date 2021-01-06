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
permHouse_10=zeros(1001,1);
permHouse_21=zeros(1001,1);
% get disitribution of spatial correlations with PG1

% get bw At 10 y.o. (from community-level modeling)
File10=['/cbica/projects/pinesParcels/results/BW_InterceptAt10_k'];
struct10=load(File10);
lh_10=struct10.datalr(1:10242);
rh_10=struct10.datalr(10243:20484);

% get bw At 21 y.o. (from community-level modeling)
File21=['/cbica/projects/pinesParcels/results/BW_InterceptAt21_k'];
struct21=load(File21);
lh_21=struct21.datalr(1:10242);
rh_21=struct21.datalr(10243:20484);

%%% get real correlation
% load in mask (SNR Mask)
surfML = '/cbica/projects/pinesParcels/data/H_SNR_masks/lh.Mask_SNR.label';
mwIndVec_l = read_medial_wall_label(surfML);
Index_l = setdiff([1:10242], mwIndVec_l);
surfMR = '/cbica/projects/pinesParcels/data/H_SNR_masks/rh.Mask_SNR.label';
mwIndVec_r = read_medial_wall_label(surfMR);
Index_r = setdiff([1:10242], mwIndVec_r);

% set masked areas explicitly to NA
lh_10(mwIndVec_l)=NaN;
rh_10(mwIndVec_r)=NaN;
merged_10=[lh_10 rh_10];
lh_21(mwIndVec_l)=NaN;
rh_21(mwIndVec_r)=NaN;
merged_21=[lh_21 rh_21];
 	
%% get real correlations
realrho_10=corr(merged_10',pg1','type','spearman','rows','complete');
permHouse_10(1,1)=realrho_10;
realrho_21=corr(merged_21',pg1','type','spearman','rows','complete');
permHouse_21(1,1)=realrho_21;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
%%% get permuted correlations
permutFile=strcat(outdir,'PGPermuts.mat');
permuts=load(permutFile);
permutsL=permuts.bigrotl;
permutsR=permuts.bigrotr;	
% change 100 (markers of invalid vertices) to NA
permutsL(permutsL==100)=NaN;
permutsR(permutsR==100)=NaN;
% for each permutation
for P=1:1000
	permutVals=[permutsL(P,:) permutsR(P,:)];
	permrho_10=corr(permutVals',merged_10','type','spearman', 'rows','complete');
	permHouse_10(1+P,1)=permrho_10;
        permrho_21=corr(permutVals',merged_21','type','spearman', 'rows','complete');
        permHouse_21(1+P,1)=permrho_21;	
end
% write out distribution, R friendly format
writetable(array2table(permHouse_10),strcat(outdir,'SpinTestDistrs_At10_PG1.csv'),'Delimiter',',','QuoteStrings',true);
writetable(array2table(permHouse_21),strcat(outdir,'SpinTestDistrs_At21_PG1.csv'),'Delimiter',',','QuoteStrings',true);
