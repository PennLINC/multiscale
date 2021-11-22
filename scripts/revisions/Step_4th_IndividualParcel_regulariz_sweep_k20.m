
%
% Based on the group atlas, creating each subject's individual specific atlas
% For the toolbox of single brain parcellation, see: 
%

% add in all supporter functions
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
addpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Step_2nd_SingleParcellation');

% set scales to sweep
scales=[4,20];
% tmp just to do 20
K=20
%for s=1:2
%K=scales(s);
%%%%%%%%%%%%

ProjectFolder = '/cbica/projects/pinesParcels/data/SingleParcellation';
ResultantFolder = [ProjectFolder '/SingleParcel_1by1_kequal_' num2str(K)];
mkdir(ResultantFolder);

PrepDataFile = [ProjectFolder '/CreatePrepData.mat'];
resId = 'IndividualParcel_Final';
initName = [ProjectFolder '/RobustInitialization_' num2str(K) '/init.mat'];

%alphaVals=[{1,1,2,2,2,;5,20,5,10,20}];
%alphaValStrings=[{'one','one','two','two','two';'five','twenty','five','ten','twenty'}];
% set alphaS21 and alphaL's to sweep
alphaVals=[{.5,.5,.5,1,1,2,2,2,;5,10,20,5,20,5,10,20}];
% make a string version for writeout : script was getting confused with decimals
alphaValStrings=[{'point5','point5','point5','one','one','two','two','two';'five','ten','twenty','five','twenty','five','ten','twenty'}];
% sweep over 8 alpha combos
for a=1:8
alphaS21 = alphaVals{1,a};
alphaL = alphaVals{2,a};
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
for i = 1:length(LeftCell)
    i
    [Fold, ~, ~] = fileparts(LeftCell{i});
    [~, ID_Str, ~] = fileparts(Fold);
    ID = str2num(ID_Str);
    ResultantFolder_I = [ResultantFolder '/Sub_' ID_Str '/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_' alphaValStrings{1,a} '_alphaL' alphaValStrings{2,a} '_vxInfo1_ard0_eta0/'];
	% does not work on .5 params (testing to see if complete already, .5 converted to 1 as string downstream in pipeline)
    ResultantFile = [ResultantFolder_I 'IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_' num2str(alphaS21) '_alphaL' num2str(alphaL) '_vxInfo1_ard0_eta0/final_UV.mat'];
    if ~exist(ResultantFile, 'file');
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
    	pause(20)
	end
end

% end alpha sweep
end

% end scale sweep
%tmp
%end
