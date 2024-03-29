
%
% Based on the group atlas, creating each subject's individual specific atlas
% For the toolbox of single brain parcellation, see: 
%

% comment out clear so K can penetrate
%clear

ProjectFolder = '/cbica/projects/pinesParcels/data/SingleParcellation';
ResultantFolder = [ProjectFolder '/SingleParcel_1by1_kequal_' num2str(K)];
mkdir(ResultantFolder);

PrepDataFile = [ProjectFolder '/CreatePrepData.mat'];
resId = 'IndividualParcel_Final';
initName = [ProjectFolder '/RobustInitialization_' num2str(K) '/init.mat'];
% Use parameter in Hongming's NeuroImage paper
alphaS21 = 1;
alphaL = 10;
vxI = 1;
spaR = 1;
ard = 0;
iterNum = 30;
eta = 0;
calcGrp = 0;
parforOn = 0;

SubjectsFolder = '/cbica/software/external/freesurfer/centos7/5.3.0/subjects/fsaverage5';
% for surface data
surfML = '/cbica/projects/pinesParcels/data/H_SNR_masks/lh.Mask_SNR.label'
surfMR = '/cbica/projects/pinesParcels/data/H_SNR_masks/rh.Mask_SNR.label'

RawDataFolder = '/cbica/projects/pinesParcels/data/CombinedData';
LeftCell = g_ls([RawDataFolder '/*/lh.fs5.sm6.residualised.mgh']);
RightCell = g_ls([RawDataFolder '/*/rh.fs5.sm6.residualised.mgh']);

% Parcellate for each subject separately
% for i = 1:length(LeftCell)
% tmp
for i=1
    i
    [Fold, ~, ~] = fileparts(LeftCell{i});
    [~, ID_Str, ~] = fileparts(Fold);
    ID = str2num(ID_Str);
    ResultantFolder_I = [ResultantFolder '/Sub_' ID_Str];
    ResultantFile = [ResultantFolder_I '/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_1_alphaL10_vxInfo1_ard0_eta0/final_UV.mat'];
    %if ~exist(ResultantFile, 'file');
        mkdir(ResultantFolder_I);
        IDMatFile = [ResultantFolder_I '/ID.mat'];
        save(IDMatFile, 'ID');

        sbjListFile = [ResultantFolder_I '/sbjListAllFile_' num2str(i) '.txt'];
        system(['rm ' sbjListFile]);

        cmd = ['echo ' LeftCell{i} ' >> ' sbjListFile];
        system(cmd);
        cmd = ['echo ' RightCell{i} ' >> ' sbjListFile];
        system(cmd);

        save([ResultantFolder_I '/Configuration.mat'], 'sbjListFile', 'surfML', 'surfMR', 'PrepDataFile', 'ResultantFolder_I', 'resId', 'initName', 'K', 'alphaS21', 'alphaL', 'vxI', 'spaR', 'ard', 'eta', 'iterNum', 'calcGrp', 'parforOn');
        ScriptPath = [ResultantFolder_I '/tmp'];
	logpath = [ResultantFolder_I '/ParcelFinal.log']
        cmd = ['diary ' logpath ' ,addpath(genpath(''/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'')),' ...
          'load(''' ResultantFolder_I '/Configuration.mat''),' ...
          'deployFuncMvnmfL21p1_func_surf_fs(sbjListFile,surfML,surfMR,' ...
          'PrepDataFile,ResultantFolder_I,resId,initName,K,alphaS21,' ...
          'alphaL,vxI,spaR,ard,eta,iterNum,calcGrp,parforOn),exit(1),'];
        fid = fopen(strcat(ScriptPath, '.m'), 'w');
        fprintf(fid, cmd);
        system(['qsub -l h_vmem=10G /cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/qsub_matlab.sh ' ScriptPath]);
    	pause(40)
	%end
end


