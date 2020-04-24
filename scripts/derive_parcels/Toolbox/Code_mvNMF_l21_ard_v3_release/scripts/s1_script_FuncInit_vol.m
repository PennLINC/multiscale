clc;
clear;

%addpath(genpath('C:\Users\LiHon\Google Drive\Code\Inhouse\ongoing\Code_mvNMF_l21_ard_v3_release\Release'));
addpath(genpath('D:\Google_drive\Code\Inhouse\ongoing\Code_mvNMF_l21_ard_v3_release\Release'));

sbjListFile = 'F:\data\test_brain_decomp_release\data\pnc_vol\pnc_vol_sbjLst.txt';
maskFile = 'F:\data\test_brain_decomp_release\data\MNI-maxprob-thr50-3mm-mask.nii.gz';
prepDataFile = 'F:\data\test_brain_decomp_release\res\pnc_vol\prepData.mat';
outDir = ['F:\data\test_brain_decomp_release\res\pnc_vol', filesep, 'init_r2'];
spaR = 1;
vxI = 0;
ard = 1;
iterNum = 1000;
K = 17;
tNum = 118;
alpha = 2;
beta = 10;
resId = 'pnc_vol';

deployFuncInit_vol(sbjListFile,maskFile,prepDataFile,outDir,spaR,vxI,ard,iterNum,K,tNum,alpha,beta,resId);
