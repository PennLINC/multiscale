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

