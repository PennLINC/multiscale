% load it all in
Scalefn='/cbica/projects/pinesParcels/results/aggregated_data/vertices_sScale';
ScalefnP='/cbica/projects/pinesParcels/results/aggregated_data/vertices_sScalep';
ScaleAgefn='/cbica/projects/pinesParcels/results/aggregated_data/vertices_AgeXScale';
ScaleAgefnP='/cbica/projects/pinesParcels/results/aggregated_data/vertices_AgeXScalep';
ScaleEFfn='/cbica/projects/pinesParcels/results/aggregated_data/vertices_EFXScale';
ScaleEFfnP='/cbica/projects/pinesParcels/results/aggregated_data/vertices_EFXScalep';
Scale=load(Scalefn);
ScaleP=load(ScalefnP);
ScaleAge=load(ScaleAgefn);
ScaleAgeP=load(ScaleAgefnP);
ScaleEF=load(ScaleEFfn);
ScaleEFP=load(ScaleEFfnP);

% Part I - save em out in r-friendly format
writetable(table(ScaleP.s_Scalep),'/cbica/projects/pinesParcels/results/aggregated_data/Scale_GEE_vertPs.csv');
writetable(table(ScaleAgeP.AgeXScalep),'/cbica/projects/pinesParcels/results/aggregated_data/AgexScale_GEE_vertPs.csv');
writetable(table(ScaleEFP.EFXScalep),'/cbica/projects/pinesParcels/results/aggregated_data/EFxScale_GEE_vertPs.csv');

% 14/1/21 - FDR CORRECTING IN R JUST BECAUSE CUBIC HAS NOT HAD ANY AVAILABLE - CHUNK BELOW NOT UTILIZED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get FDR'ed pvalues (If our corporate matlab overlords permit, limited licenses for statistics toolbox on cubic)
%ScaleFDR=mafdr(ScaleP.s_Scalep);
%ScaleAgeFDR=mafdr(ScaleAgeP.AgeXScalep);
%ScaleEFFDR=mafdr(ScaleEFP.EFXScalep);
% create mask of where p-fdr > 0.05
%ScaleinSig=find(ScaleFDR > 0.05);
%ScaleAgeinSig=find(ScaleAgeFDR > 0.05);
%ScaleEFinSig=find(ScaleEFFDR > 0.05);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% part II (after FDR correction)
ScaleP_postR=load('/cbica/projects/pinesParcels/results/EffectVecs/ScaleP_FDRed');
ScaleAgeP_postR=load('/cbica/projects/pinesParcels/results/EffectVecs/ScaleAgeP_FDRed');
ScaleEFP_postR=load('/cbica/projects/pinesParcels/results/EffectVecs/ScaleEFP_FDRed');
ScaleinSig=find(ScaleP_postR > 0.05);
ScaleAgeinSig=find(ScaleAgeP_postR > 0.05);
ScaleEFinSig=find(ScaleEFP_postR > 0.05);
% extract statistics
ScaleChiSq=Scale.s_Scale;
ScaleAgeChiSq=ScaleAge.AgeXScale;
ScaleEFChiSq=ScaleEF.EFXScale;
% mask chi-sq stats where p-fdr > 0.05
ScaleChiSq(ScaleinSig)=0;
ScaleAgeChiSq(ScaleAgeinSig)=0;
ScaleEFChiSq(ScaleEFinSig)=0;
% save em out
save('/cbica/projects/pinesParcels/results/aggregated_data/Scale_GEE_FDRed_verts','ScaleChiSq');
save('/cbica/projects/pinesParcels/results/aggregated_data/ScaleAge_GEE_FDRed_verts','ScaleAgeChiSq');
save('/cbica/projects/pinesParcels/results/aggregated_data/ScaleEF_GEE_FDRed_verts','ScaleEFChiSq');
% save out a version of raw p < 0.05 thresholding for comparison
ScaleinSig_nofdr=find(ScaleP.s_Scalep > 0.05);
ScaleAgeinSig_nofdr=find(ScaleAgeP.AgeXScalep > 0.05);
ScaleEFinSig_nofdr=find(ScaleEFP.EFXScalep > 0.05);
ScaleChiSq=Scale.s_Scale;
ScaleAgeChiSq=ScaleAge.AgeXScale;
ScaleEFChiSq=ScaleEF.EFXScale;
ScaleChiSq(ScaleinSig_nofdr)=0;
ScaleAgeChiSq(ScaleAgeinSig_nofdr)=0;
ScaleEFChiSq(ScaleEFinSig_nofdr)=0;
save('/cbica/projects/pinesParcels/results/aggregated_data/Scale_GEE_verts','ScaleChiSq');
save('/cbica/projects/pinesParcels/results/aggregated_data/ScaleAge_GEE_verts','ScaleAgeChiSq');
save('/cbica/projects/pinesParcels/results/aggregated_data/ScaleEF_GEE_verts','ScaleEFChiSq');
