# neurodevelopmental functional network organization across scales

Steps are organized by units of analyses and construct of interest. You can also search by figure number to find specific analyses. 

Step 1: Derive Group/Individual Parcels, Derive Parcel Properties, Extract FC

Step 2: Network-level: Age

Step 3: Network-level : Executive Function

Step 4: Network-level : Mediation

Step 5: Vertex-level : Age and Scale

Step 6: Vertex-level : Executive Function

Step 7: Age: Edge-level

Step 8: EF: Edge-level

# Step 1: Derive Group/Individual Parcels, Derive Parcel Properties, Extract FC

## 1A) Derive group parcels:
###### [scripts/derive_parcels/iterate_nmf_overscales.m](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_parcels/iterate_nmf_overscales.m) - parent loop for group/single-subject parcellations over scales
###### [scripts/derive_parcels/Step_2nd_SingleParcellation/Step_1st_CreatePrepData_AP.m](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_parcels/Step_2nd_SingleParcellation/Step_1st_CreatePrepData_AP.m) - prepare data for pipeline
###### [Step_2nd_ParcellationInitialize_AP.m](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_parcels/Step_2nd_SingleParcellation/Step_2nd_ParcellationInitialize_AP.m) - group consensus (takes > 6 weeks to run over all scales w/ cubic limitations)
###### [Step_3rd_SelRobustInit_AP.m](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_parcels/Step_2nd_SingleParcellation/Step_3rd_SelRobustInit_AP.m) - prepare individ. data for parcels
###### [Step_4th_IndividualParcel_AP.m](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_parcels/Step_2nd_SingleParcellation/Step_4th_IndividualParcel_AP.m) - individualization
###### [Step_5th_AtlasInformation_Extract_AP.m](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_parcels/Step_2nd_SingleParcellation/Step_5th_AtlasInformation_Extract_AP.m) - minor reorganization of some output
###### [Step_6th_GroupAtlas_Extract_AP.m](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_parcels/Step_2nd_SingleParcellation/Step_6th_GroupAtlas_Extract_AP.m) - minor reorganization/converting of some output
###### [Step_7th_NetworkNaming_Yeo_AP.m](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_parcels/Step_2nd_SingleParcellation/Step_7th_NetworkNaming_Yeo_AP.m) - find predominant yeo7/17 overlap and extent of overlap

## 1B) Derive Parcel Properties - Figure 1
###### [scripts/derive_netstats/error_over_scales](https://github.com/PennLINC/multiscale/blob/aedb458dabec6d1530e829ff73fb2e18c8d6f523/scripts/derive_netstats/error_over_scales.m) - calculates reconstruction error over scales for each subject. Iterates over script below
###### [scripts/derive_netstats/calc_recon_error.m](https://github.com/PennLINC/multiscale/blob/aedb458dabec6d1530e829ff73fb2e18c8d6f523/scripts/derive_netstats/calc_recon_error.m) - analysis for figure 1A
###### [scripts/derive_spatialprops/group_All_Ks_export2R.m](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_spatialprops/group_All_Ks_export2R.m) - export for figure 1B
###### scripts/derive_parcels/Toolbox/PBP/PBP_final/PBP_GroCon.m* - figure 1C
	
## 1C) Derive Parcel Properties - Figure 2
###### scripts/derive_parcels/Toolbox/PBP/PBP_final/PBP_SSCon.m* - for Figure 2A
###### [scripts/derive_parcels/Step_2nd_SingleParcellation/Step_9th_1_Visualize_Workbench_AtlasVariability_AP.m](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_parcels/Step_2nd_SingleParcellation/Step_9th_1_Visualize_Workbench_AtlasVariability_AP.m) - for MAD calculation
###### scripts/derive_parcels/Toolbox/PBP/PBP_final/PBP_MAD.m* - for Figure 2B
###### [scripts/derive_spatialprops/SpinTest_MAD.m](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_spatialprops/SpinTest_MAD.m) - Spin MAD maps for correlation null distributions
###### [scripts/derive_spatialprops/calc_spinDistribs_MAD_PG.m](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_spatialprops/calc_spinDistribs_MAD.m) - Calculate real and permuted MAD-PG1 correlations - for figure 2B and C
Subsequent R code for figure 2B + C within [_Vertex-level-MAD_PG.md_](https://github.com/PennLINC/multiscale/blob/master/scripts/analyses/Vertex-level-MAD_PG.md)

## 1D) Extract FC values from individual parcels and .mgh timeseries
###### [scripts/derive_netstats/iterate_vert_fc.m](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_netstats/iterate_vert_fc.m) - script to iterate qsubs over FC matrix derivations from subject time series and individualized parcels
###### [scripts/derive_netstats/subj_vert_fc.m](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_netstats/subj_vert_fc.m) - the individual-level script ran on individual compute nodes *compiled (c++) version exists to deal with paucity of stats toolbox licenses available, not reccomended for small runs unless licenses unavailable* 
###### [scripts/derive_netstats/merge_ind_fc.m](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_netstats/merge_ind_fc.m) - merge individual derivations into cross-subject, cross-scale 3D matrices (matlab struct)
###### [scripts/derive_netstats/fc_to_csv.m](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_netstats/fc_to_csv.m) - likely the densest script in the entire project. Designed to take in fake data and spit out corresponding FC matrices + summary columns for sanity check.
###### [scripts/derive_netstats/round_master_fcfeats.r](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_netstats/round_master_fcfeats.r) - file master fc feats takes almost 10 minutes to load without rounding. no need for the many decimal places defaulted to by matlab.

# Step 2: Network-level: Age
## 2A) Network-level Generalized Additive Models - Figures 3 and 5
All within [_Network-level-age.md_](https://github.com/PennLINC/multiscale/blob/master/scripts/analyses/Network-level-age.md)
###### B/w * Age - for figure 3B
###### Age Effect * Transmodality - for figure 3C
###### Age Effect derivative over Age (* Transmodality) - for figure 3D
###### Scale Effect on Age Effect (* Transmodality) - for figure 5C

## 2B)	Cross-scale averaging & vertex-mapping - Figure 3
###### *All vectors to be visualized (Predicted b.w. at ages 10 and 21, age effect derivatives at 10,16,21) are printed out from [_Network-level-age.md_](https://github.com/PennLINC/multiscale/blob/master/scripts/analyses/Network-level-age.md) above: to aggregate visualize these vectors into a single scale-wise matlab structure, use these matlab scripts:
###### [scripts/viz/overlay_overscales_effects_onto_fsaverage_intercept.m](https://github.com/PennLINC/multiscale/blob/master/scripts/viz/overlay_overscales_effects_onto_fsaverage_intercept.m) - to overlay estimated b.w. at ages 10 and 21
###### [scripts/viz/overlay_overscales_effects_onto_fsaverageDeriv.m](https://github.com/PennLINC/multiscale/blob/master/scripts/viz/overlay_overscales_effects_onto_fsaverageDeriv.m) - to overlay age effect derivatives at ages 10, 16 and 21
###### to plot scale-wise matlab structures, the scripts above will leverage the following script:
###### scripts/derive_parcels/Toolbox/PBP/PBP_final/PBP_effect_msOverlay_2View_R_lPFC.m*

# Step 3: Network-level : Executive Function
## 3A) Network-level Generalized Additive Models - Figure 6
All within [_Network-level-ef.md_](https://github.com/PennLINC/multiscale/blob/master/scripts/analyses/Network-level-EF.knit.md)
###### EF Effect * Transmodality - for figure 6C
###### Scale Effect on EF Effect (* Transmodality) - for figure 6D

# Step 4: Network-level : Mediation
## 4A) Network-level Generalized Additive Models - Figure 7
All within [_Network-level-mediation.md_](https://github.com/PennLINC/multiscale/blob/master/scripts/analyses/Network-level-Mediation.knit.md)
###### Mediation Weight * Transmodality - for figure 6C
###### Scale Effect on Mediation Weight (* Transmodality) - for figure 6D

# Step 5: Vertex-level : Age and Scale
###### [scripts/derive_GEE_stats/DemoData_to_Matlab.R](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_GEE_stats/DemoData_to_Matlab.R) - Prepare "forMLpc.csv" in R (for matlab) 
###### [scripts/derive_netstats/Win_Bw_Age_vertwise.m](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_netstats/Win_Bw_Age_vertwise.m) - save out cross-scale values for each subject for each vertex, bringing matrix dimensionality back down to 2
###### scp all vertex-level .csv files to pmacs
###### xbash module load R/3.6.3 - for consistent versioning of mgcv, doBy, geepack, reshape2. Should also take you to a bbl/linc compute node
###### loop over qsub_vertWise.sh - i.e: 
> for i in {1..17734}; do bsub ./qsub_vertWise.sh $i; echo $i; done
###### the command above iterates over [scripts/vert_GEE_looper.r](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_GEE_stats/vert_GEE_looper.R)
###### scp all vertex-level GEE stats back out to cubic
###### [scripts/derive_GEE_stats/aggregate_GEE_Effects.m](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_GEE_stats/aggregate_GEE_Effects.m) - pull all vertex-level stats into one dataframe
###### [scripts/derive_GEE_stats/FDR_GEEs_pt1.m](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_GEE_stats/FDR_GEEs_pt1.m) - print out effects in R-friendly format for FDR correction. This is due to matlab limitation in available stat toolbox licenses. *Requires pre-FDR EF to be run with no commenting out*
###### [scripts/derive_GEE_stats/FDR_GEEs_1point5.R](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_GEE_stats/FDR_GEEs_1point5.R) FDR correct in R
###### [scripts/derive_GEE_stats/FDR_GEEs_pt2](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_GEE_stats/FDR_GEEs_pt2.m) - re-aggregate FDR-corrected vertices - current output filepaths set to results/aggregated_data/*_GEE_FDRed_verts
###### scripts/derive_parcels/Toolbox/PBP/PBP_final/PBP_vertWiseEffect4View.m* - run with fdr-corrected vertices for final brainmaps

# Step 6: Vertex-level : Executive Function
###### Files should all already be on pmacs from step 5.
###### xbash module load R/3.6.3 - for consistent versioning of mgcv, doBy, geepack, reshape2. Should also take you to a bbl/linc compute node
###### loop over qsub_vertWise_EF.sh - i.e: 
> for i in {1..17734}; do bsub ./qsub_vertWise_EF.sh $i; echo $i; done
###### the command above iterates over [scripts/vert_GEE_looper_EF.r](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_GEE_stats/vert_GEE_looper_EF.R)
###### scp all vertex-level GEE stats back out to cubic
###### [scripts/derive_GEE_stats/aggregate_GEE_Effects_EF.m](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_GEE_stats/aggregate_GEE_Effects_EF.m) - pull all vertex-level stats into one dataframe
###### [scripts/derive_GEE_stats/FDR_GEEs_pt1.m](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_GEE_stats/FDR_GEEs_pt1.m) - print out effects in R-friendly format for FDR correction. This is due to matlab limitation in available stat toolbox licenses.
###### [scripts/derive_GEE_stats/FDR_GEEs_1point5.R](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_GEE_stats/FDR_GEEs_1point5.R) FDR correct in R
###### [scripts/derive_GEE_stats/FDR_GEEs_pt2](https://github.com/PennLINC/multiscale/blob/master/scripts/derive_GEE_stats/FDR_GEEs_pt2.m) - re-aggregate FDR-corrected vertices - current output filepaths set to results/aggregated_data/*_GEE_FDRed_verts
###### scripts/derive_parcels/Toolbox/PBP/PBP_final/PBP_vertWiseEffect4View.m* - run with fdr-corrected vertices for final brainmaps

# Step 7: Age: Edge-level
## 7A) Edge-level Generalized Additive Models - Figure 4
All within [_Edge-level-age.md_](https://github.com/PennLINC/multiscale/blob/master/scripts/analyses/Edge-level-Age.md)

# Step 8: EF: Edge-level
## 8A and 8C) Pre and post-ridge - Figure 6
within [ Edge-level-EF.md ](https://github.com/PennLINC/multiscale/blob/master/scripts/analyses/Edge-level-EF.md)
## 8B) Penalized regression portion 
within [ penal_regresFC_AgeEFIndep.py ](https://github.com/PennLINC/multiscale/blob/master/scripts/penalized_regression/penal_regresFC_AgeEFIndep.py)
(Python environment: source activate mv_preds)





\* scripts not linked are intentionally hidden by .gitignore. Largely code written by others.
