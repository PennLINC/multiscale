% addpaths
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
% set outdir
outdir='/cbica/projects/pinesParcels/results/aggregated_data/';
% set paths
ProjectFolder = '/cbica/projects/pinesParcels/data/princ_gradients';
% get gradient change maps
fnR=strcat('/cbica/projects/pinesParcels/results/aggregated_data/changeVec_PG1_R.mat');
fnL=strcat('/cbica/projects/pinesParcels/results/aggregated_data/changeVec_PG1_L.mat');
gradChangeL=load(fnL);
gradChangeR=load(fnR);
grad_lh=gradChangeL.VertexChange;
grad_rh=gradChangeR.VertexChange;
pg1=[grad_lh grad_rh];
% initialize permutation house for correlations for 1000 spins across scales, +1 row for real correlation
permHouse=zeros(1001,29);
% for each scale, get distribution of spatial correlations with PG1
for K=2:30
	disp(K)
	%%% get real correlation
	% get real map
	changeValsFnL=strcat(outdir,'changeVec_',num2str(K),'_L.mat');
	changeValsFnR=strcat(outdir,'changeVec_',num2str(K),'_R.mat');
	changeValsL_file=load(changeValsFnL);
	changeValsR_file=load(changeValsFnR);
	changeValsL=changeValsL_file.VertexChange;
	changeValsR=changeValsR_file.VertexChange;
	% mask files, set non-mask numbas to 100
	% load in mask (should be the same for all scales)
	Extended_maskFnL=strcat(outdir,'Border_excludeVec_',num2str(K),'_L.mat');
	Extended_maskFnR=strcat(outdir,'Border_excludeVec_',num2str(K),'_R.mat');
	Extended_mask_file_L=load(Extended_maskFnL);
	Extended_mask_file_R=load(Extended_maskFnR);
	Extended_mask_L=Extended_mask_file_L.VertexExclude;
	Extended_mask_R=Extended_mask_file_R.VertexExclude;
	% set masked vertices to NaN
	changeValsL(Extended_mask_L==1)=NaN;
	changeValsR(Extended_mask_R==1)=NaN;
	changeVals=[changeValsL changeValsR];	
	%% get real correlation
	realrho=corr(pg1',changeVals','type','spearman','rows','complete');
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
		permrho=corr(pg1',permutVals','type','spearman', 'rows','complete');
		permHouse(1+P,(K-1))=permrho;
	end
end
% write out distribution, R friendly format
writetable(array2table(permHouse),strcat(outdir,'SpinTestDistrs.csv'),'Delimiter',',','QuoteStrings',true);
