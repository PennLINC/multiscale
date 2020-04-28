
%
% The second step of single brain parcellation, clustering of 50 group atlas to create the final group atlas
% For the toolbox of single brain parcellation, see: 
%

% clear removed so K can penetrate
%clear

projectFolder = '/cbica/projects/pinesParcels/data/SingleParcellation';
resultantFolder = [projectFolder '/RobustInitialization_' num2str(K)];
mkdir(resultantFolder);
% commenting this out for first iter because no previous script seems to create it, gets confused when it tries to rm nonexistant file
inFile = [resultantFolder '/ParcelInit_List.txt'];
%system(['rm ' inFile]);
% changed to only detect init.mat at this particular K
AllFiles = g_ls([projectFolder '/Initialization/*/*comp' num2str(K) '*/*.mat']);
for i = 1:length(AllFiles)
  cmd = ['echo ' AllFiles{i} ' >> ' inFile];
  system(cmd);
end

% Parcellate into K networks (K commented out because it is set in iterative loop prior to calling this)
selRobustInit(inFile, K, resultantFolder);
