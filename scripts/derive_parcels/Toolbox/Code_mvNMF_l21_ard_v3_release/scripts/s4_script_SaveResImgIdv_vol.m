clc;
clear;

%addpath(genpath('C:\Users\LiHon\Google Drive\Code\Inhouse\ongoing\Code_mvNMF_l21_ard_v3_release\Release'));
addpath(genpath('D:\Google_drive\Code\Inhouse\ongoing\Code_mvNMF_l21_ard_v3_release\Release'));

resFileName = 'F:\data\test_brain_decomp_release\res\pnc_vol\res\pnc_vol_sbj5_comp17_alphaS21_10_alphaL10_vxInfo0_ard1_eta1\final_UV.mat';
maskName = 'F:\data\test_brain_decomp_release\data\MNI-maxprob-thr50-3mm-mask.nii.gz';
outDir = 'F:\data\test_brain_decomp_release\res\pnc_vol\res\pnc_vol_sbj5_comp17_alphaS21_10_alphaL10_vxInfo0_ard1_eta1\fig_idv';
saveFig = 1;
refNiiName = 'F:\data\test_brain_decomp_release\data\MNI-maxprob-thr50-3mm-mask.nii.gz';
sbjId = 3;

func_saveVolRes2Nii_idv(resFileName,maskName,sbjId,outDir,saveFig,refNiiName);
