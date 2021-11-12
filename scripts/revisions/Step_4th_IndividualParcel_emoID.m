% this script exists to extract the rs, nb, and eID time series

% add in all supporter functions
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
addpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Step_2nd_SingleParcellation');

% foldernames below use this parent fp
ProjectFolder = '/cbica/projects/pinesParcels/data/SingleParcellation';

% set nmf parameters
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

% load in surfaces
surfML = '/cbica/projects/pinesParcels/data/H_SNR_masks/lh.Mask_SNR.label';
surfMR = '/cbica/projects/pinesParcels/data/H_SNR_masks/rh.Mask_SNR.label';

% get name of initialization parcellation
initName = [ProjectFolder '/RobustInitialization_' num2str(K) '/init.mat'];

% location of the merged time series, load it into list
RawDataFolder = '/cbica/projects/pinesParcels/data/CombinedData';
LeftCell = g_ls([RawDataFolder '/*/lh.fs5.sm6.residualised.mgh']);
RightCell = g_ls([RawDataFolder '/*/rh.fs5.sm6.residualised.mgh']);

% establish parent filepaths for modalities
rsParent='/cbica/projects/pncSingleFuncParcel/pncSingleFuncParcel_psycho/data/SurfaceData/RestingState/';
nbParent='/cbica/projects/pncSingleFuncParcel/pncSingleFuncParcel_psycho/data/SurfaceData/NBack/';
eIDParent='/cbica/projects/pncSingleFuncParcel/pncSingleFuncParcel_psycho/data/SurfaceData/EmotionIden/';

% establish output folder
ProjectFolder = '/cbica/projects/pinesParcels/data/SingleParcellation';
ResultantFolder = [ProjectFolder '/SingleParcel_1by1_kequal_' num2str(K)];

% extract and save extracted TSes for each subj
% test on 1 subj
%for i=1
for i = 1:length(LeftCell)
	% extract subj ID
	[Fold, ~, ~] = fileparts(LeftCell{i});
	[~, ID_Str, ~] = fileparts(Fold);	
	ID = str2num(ID_Str);
	% load in RESTING for this subject
	RStsFP_l=[rsParent ID_Str '/surf/lh.fs5.sm6.residualised.mgh'];
	RStsFP_r=[rsParent ID_Str '/surf/rh.fs5.sm6.residualised.mgh'];
	% nback
	NBtsFP_l=[nbParent ID_Str '/surf/lh.fs5.sm6.residualised.mgh'];
        NBtsFP_r=[nbParent ID_Str '/surf/rh.fs5.sm6.residualised.mgh'];
	% emo ID
	eIDtsFP_l=[eIDParent ID_Str '/surf/lh.fs5.sm6.residualised.mgh'];
        eIDtsFP_r=[eIDParent ID_Str '/surf/rh.fs5.sm6.residualised.mgh'];
	% output folder for this subj	
	ResultantFolder_I = [ResultantFolder '/Sub_' ID_Str '/emoID_only'];
	ResultantFile = [ResultantFolder_I '/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_1_alphaL10_vxInfo1_ard0_eta0/final_UV.mat'];
	if ~exist(ResultantFile, 'file');
		% print iteration
		i
		mkdir(ResultantFolder_I)
		% EMO ID JOB SUBMISSION
                % keep subject list file fresh
                sbjListFile = [ResultantFolder_I '/sbjListAllFile_' num2str(i) '.txt'];
                system(['rm ' sbjListFile]);
                % Insert filepaths to subject list file
                cmd = ['echo ' eIDtsFP_l ' >> ' sbjListFile];
                system(cmd);
                cmd = ['echo ' eIDtsFP_r ' >> ' sbjListFile];
                system(cmd);
                % save mat file for individualized NMF job
                save([ResultantFolder_I '/Configuration.mat'], 'sbjListFile', 'surfML', 'surfMR', 'PrepDataFile', 'ResultantFolder_I', 'resId', 'initName', 'K', 'alphaS21', 'alphaL', 'vxI', 'spaR', 'ard', 'eta', 'iterNum', 'calcGrp', 'parforOn');
                % Set script path
                ScriptPath = [ResultantFolder_I '/tmp'];
                % set logdir
                logpath = [ResultantFolder_I '/ParcelFinal.log'];
                % matlab command
                cmd = ['diary ' logpath ' ,addpath(genpath(''/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'')),' ...
          'load(''' ResultantFolder_I '/Configuration.mat''),' ...
          'deployFuncMvnmfL21p1_func_surf_fs(sbjListFile,surfML,surfMR,' ...
          'PrepDataFile,ResultantFolder_I,resId,initName,K,alphaS21,' ...
          'alphaL,vxI,spaR,ard,eta,iterNum,calcGrp,parforOn),exit(1),'];
                % print it in
                fid = fopen(strcat(ScriptPath, '.m'), 'w');
                fprintf(fid, cmd);
                % sge command
                system(['qsub -l h_vmem=9G,s_vmem=8G /cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/qsub_matlab.sh ' ScriptPath]);
                % space it out
                pause(20);
	end
end
