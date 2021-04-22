addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));


% directory where input data is stored. update to your own directory
inputdir = '/cbica/projects/pinesParcels/data/aggregated_data'
% directory where results will be saved data. update to your own directory. if it doesnt exist, it will be created
outputdir = '/cbica/projects/pinesParcels/results/aggregated_data/mediation'

% read in data
% X should be a csv file with subjects on rows, where each element is Age
% AP - Changed to load bc old matlab version
X = load(fullfile(inputdir,'X.csv'));

% Y should be a csv file with subjects on rows, where each element is EF
Y = load(fullfile(inputdir,'Y.csv'));

% M should be a csv file with subjects on rows and voxels of columns, where each element is an FC edge
M = load(fullfile(inputdir,'M.csv'));

%%%%% removed by AP, appears to be only for init. dimen. reduc.
% Set number of PCs to use here. Determine this number from separate PCA
%%%%%num_pcs = 10

% set number of PDMs here
% trial run on just number of features from single scale
num_pdms = 5

% print out number of features
num_inputFeats=length(M)

% reorganize data into a bunch of cell variables (input type required for the multivariateMediation function)
xx = {}; yy = {}; mm = {};
% AP - changed numel(bblid) to 693: bblid not carried over from R dataframe
for k = 1:693
    xx{k} = X(k); % store each subject's value for X in its own cell entry
    yy{k} = Y(k); % store each subject's value for Y in its own cell entry
    mm{k} = M(k,:)'; % store each subject's brain map (M) as a vector in its own cell entry
end
xx = xx'; yy = yy'; mm = mm'; % transpose... lazy code...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copied from Multivariate_Mediation_ExampleScript.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reset the seed on matlab's random number generator
rng default

% dimensionality reduction via singular value decomposition (or PCA). No PDMs are estimated here.
pdm = multivariateMediation(xx,yy,mm,'B',num_pcs,'svd','noPDMestimation');
pdm = multivariateMediation(pdm,'nPDM',num_pdms); 


% run initial pdm. This will estimate PDMs 
%pdm = multivariateMediation(pdm,'nPDM',num_pdms);

% init dimen reduction
%pdm = multivariateMediation(xx,yy,mm,'B',20,'svd');

path_ab = zeros(1,num_pdms);
for i = 1:num_pdms
    path_ab(i) = abs(pdm.Theta{i}(5));
end

% redefine the number of PDMs by finding the PDMs that have |ab| path coefficients that are >0 up to 4 decimal places
% this might reduce the number of PDMs from the initial value we set above (on line 26)
% reducing this simply stops us from wasting time assessing significance of PDMs with |ab| path coefficients that are equal to 0
% note, you can just comment this line out and the bootstrapping below will run using the number of PDMs originally specified
%num_pdms = find(diff(round(path_ab,4) == 0));

% test for path significance
% stats will store the outputs of boostrapping. The p-values for the various paths are stored in .p
% for example, the p values for the first PDM are stored in stats{1} as a vector. This vector stores p values corresponding to the following order: a, b, c', c, ab
% as such, the p-value for the ab path for the first PDM is stored in stats{1}.p(5)
stats = cell(0);
for k = 1:num_pdms 
% like above, try both M's, test bootstrap, test equivalence of path sig.
	%m = pdm.dat.M_tilde*pdm.dat.Dt*pdm.Wfull{k};
    	% confirm W over Wfull
	m = pdm.dat.M_tilde*pdm.W{k};
	x = cell2mat(xx);
	y = cell2mat(yy);
	[paths, stats{k}] = mediation(x, y, m, 'verbose', 'boottop', 'bootsamples', 1e4, 'hierarchical');
end

% bootstrap the weights of each PDM.
% this is the second bootstrap analysis and pertains to assessing significances of the voxelwise weights associated with each PDM
% this analysis can take a while.. get a coffee.. or a beer..
% I would probably comment this out in your initial runs of this code. i.e., only run this once everything before it is dialed in.
%pdm = multivariateMediation(pdm,'noPDMestimation','bootPDM',1:num_pdms,'Bsamp',1e4);
pdm1OutFn=['/cbica/projects/pinesParcels/multiscale/scripts/highDim_mediation/PDM1_AllEdges.csv'];
csvwrite(pdm1OutFn,pdm.W{1});
pdm2OutFn=['/cbica/projects/pinesParcels/multiscale/scripts/highDim_mediation/PDM2_AllEdges.csv'];
csvwrite(pdm2OutFn,pdm.W{2});
pdm3OutFn=['/cbica/projects/pinesParcels/multiscale/scripts/highDim_mediation/PDM3_AllEdges.csv'];
csvwrite(pdm3OutFn,pdm.W{3});
pdm4OutFn=['/cbica/projects/pinesParcels/multiscale/scripts/highDim_mediation/PDM4_AllEdges.csv'];
csvwrite(pdm4OutFn,pdm.W{4});
pdm5OutFn=['/cbica/projects/pinesParcels/multiscale/scripts/highDim_mediation/PDM5_AllEdges.csv'];
csvwrite(pdm5OutFn,pdm.W{5});

% save outputs
save(strcat('PDMresults_nPDMs_',num2str(num_pdms),'.mat'), 'pdm', 'stats')

