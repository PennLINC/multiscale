clc;
clear;

addpath(genpath('C:\Users\LiHon\Google Drive\Code\Inhouse\ongoing\Code_mvNMF_l21_ard_v3_release\Release'));
%addpath(genpath('D:\Google_drive\Code\Inhouse\ongoing\Code_mvNMF_l21_ard_v3_release\Release'));


% for volumetric data
maskFile = 'F:\data\test_brain_decomp_release\data\MNI-maxprob-thr50-3mm-mask.nii.gz';
maskNii = load_untouch_nii(maskFile);

gNb = createPrepData('volumetric', maskNii.img, 1);

% for surface data
surfL = 'C:\Users\LiHon\Google Drive\Code\Inhouse\ongoing\Code_mvNMF_l21_ard_v3_release\Release\lib\freesurfer\subjects\fsaverage5\surf\lh.pial';
surfR = 'C:\Users\LiHon\Google Drive\Code\Inhouse\ongoing\Code_mvNMF_l21_ard_v3_release\Release\lib\freesurfer\subjects\fsaverage5\surf\rh.pial';
surfML = 'C:\Users\LiHon\Google Drive\Code\Inhouse\ongoing\Code_mvNMF_l21_ard_v3_release\Release\lib\freesurfer\subjects\fsaverage5\label\lh.Medial_wall.label';
surfMR = 'C:\Users\LiHon\Google Drive\Code\Inhouse\ongoing\Code_mvNMF_l21_ard_v3_release\Release\lib\freesurfer\subjects\fsaverage5\label\rh.Medial_wall.label';

[surfStru, surfMask] = getFsSurf(surfL, surfR, surfML, surfMR);

gNb = createPrepData('surface', surfStru, 1, surfMask);

% save gNb into file for later use
prepDataName = 'F:\data\test_brain_decomp_release\res\test_CreatePrepData.mat';
save(prepDataName, 'gNb');
