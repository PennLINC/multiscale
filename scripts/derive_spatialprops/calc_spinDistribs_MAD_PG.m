% addpaths
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
% set outdir
outdir='/cbica/projects/pinesParcels/results/aggregated_data/';
% set paths
ProjectFolder = '/cbica/projects/pinesParcels/data/princ_gradients';
WorkingFolder = '/cbica/projects/pinesParcels/data/SingleParcellation/SingleAtlas_Analysis';
Variability_Visualize_Folder = [WorkingFolder '/Variability_Visualize'];
% get gradient change map
fnR=strcat('/cbica/projects/pinesParcels/results/aggregated_data/changeVec_PG1_R.mat');
fnL=strcat('/cbica/projects/pinesParcels/results/aggregated_data/changeVec_PG1_L.mat');
gradChangeL=load(fnL);
gradChangeR=load(fnR);
grad_lh=gradChangeL.VertexChange;
grad_rh=gradChangeR.VertexChange;
pg1=[grad_lh grad_rh];
% initialize permutation house for correlations for 1000 spins across scales, +1 row for real correlation
permHouse=zeros(1001,29);
% for each scale, get disitribution of spatial correlations with PG1
for K=2:30
	disp(K)
	% get MAD to test
	MADFile=[Variability_Visualize_Folder '/VariabilityLabel_Scale' num2str(K) '.mat'];
	MADKstruct=load(MADFile);
	mad_lh=MADKstruct.VariabilityLabel_lh;
	mad_rh=MADKstruct.VariabilityLabel_rh;
	%%% get real correlation
	% load in mask (should be the same for all scales)
	Extended_maskFnL=strcat(outdir,'Border_excludeVec_',num2str(K),'_L.mat');
	Extended_maskFnR=strcat(outdir,'Border_excludeVec_',num2str(K),'_R.mat');
	Extended_mask_file_L=load(Extended_maskFnL);
	Extended_mask_file_R=load(Extended_maskFnR);
	Extended_mask_L=Extended_mask_file_L.VertexExclude;
	Extended_mask_R=Extended_mask_file_R.VertexExclude;
	% set masked vertices to NaN
	mad_lh(Extended_mask_L==1)=NaN;
	mad_rh(Extended_mask_R==1)=NaN;
	madk=[mad_lh mad_rh];	
	%% get real correlation
	realrho=corr(madk',pg1','type','spearman','rows','complete');
	permHouse(1,(K-1))=realrho;
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%% get permuted correlations
	permutFile=strcat(outdir,'SpatChangePermuts_',num2str(K),'.mat');
	permuts=load(permutFile);
	permutsL=permuts.bigrotl;
	permutsR=permuts.bigrotr;	
	% change 100 (markers of invalid vertices) to NA
	permutsL(permutsL==100)=NaN;
	permutsR(permutsR==100)=NaN;
	% for each permutation
	for P=1:1000
		permutVals=[permutsL(P,:) permutsR(P,:)];
		permrho=corr(madk',pg1','type','spearman', 'rows','complete');
		permHouse(1+P,(K-1))=permrho;
	end
end
% write out distribution, R friendly format
writetable(array2table(permHouse),strcat(outdir,'SpinTestDistrs_MAD_PG1.csv'),'Delimiter',',','QuoteStrings',true);
