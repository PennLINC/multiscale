clc;
clear;

addpath(genpath('C:\Users\LiHon\Google Drive\Code\Inhouse\ongoing\Code_mvNMF_l21_ard_v3_release\Release'));

sbjListFile = 'F:\data\test_brain_decomp_release\data\pnc_vol\pnc_vol_sbjLst.txt';
maskFile = 'F:\data\test_brain_decomp_release\data\MNI-maxprob-thr50-3mm-mask.nii.gz';
prepDataFile = 'F:\data\test_brain_decomp_release\res\pnc_vol\prepData.mat';
outDir = ['F:\data\test_brain_decomp_release\res\pnc_vol', filesep, 'res'];

resId = 'pnc_vol';
%initName = 'F:\data\test_brain_decomp_release\res\pnc_vol\init\pnc_vol_num5_comp17_S1_69_L_17_spaR_1_vxInfo_0_ard_1\init.mat';
initName = 'F:\data\test_brain_decomp_release\res\pnc_vol\robustInit\init.mat';
K = 17;
alphaS21 = 2;
alphaL = 10;
vxI = 0;
spaR = 1;
ard = 1;
eta = 1;
iterNum = 30;
calcGrp = 1;
parforOn = 0;

deployFuncMvnmfL21p1_func_vol(sbjListFile,maskFile,prepDataFile,outDir,resId,initName,K,alphaS21,alphaL,vxI,spaR,ard,eta,iterNum,calcGrp,parforOn);
