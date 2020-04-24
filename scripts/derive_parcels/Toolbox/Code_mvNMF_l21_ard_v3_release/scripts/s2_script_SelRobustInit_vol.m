clc;
clear;

%addpath(genpath('C:\Users\LiHon\Google Drive\Code\Inhouse\ongoing\Code_mvNMF_l21_ard_v3_release\Release'));
addpath(genpath('D:\Google_drive\Code\Inhouse\ongoing\Code_mvNMF_l21_ard_v3_release\Release'));


candidateLstFile = 'F:\data\test_brain_decomp_release\res\pnc_vol\init_cand_lst.txt';
outDir = 'F:\data\test_brain_decomp_release\res\pnc_vol\robustInit';
K = 17;

initV = selRobustInit(candidateLstFile,K,outDir);
