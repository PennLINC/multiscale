# neurodevelopmental functional community organization across scales

###### Final common pathway / analyses are in scripts/analyses/BwRsqCentricOverview.Rmd. Precursor scripts/ordering listed below. 

# Step 1: Derive Group/Individual Parcels, Derive Parcel Properties, Extract FC

## 1A) Derive group parcels:
###### scripts/derive_parcels/iterate_nmf_overscales.m - parent loop for group/single-subject parcellations over scales
###### /scripts/derive_parcels/Step_2nd_SingleParcellation/Step_1st_CreatePrepData_AP.m - prepare data for pipeline
###### Step_2nd_ParcellationInitialize_AP.m - group consensus (takes > 6 weeks to run over all scales w/ cubic limitations)
###### Step_3rd_SelRobustInit_AP.m - prepare individ. data for parcels
###### Step_4th_IndividualParcel_AP.m - individualization
###### Step_5th_AtlasInformation_Extract_AP.m - minor reorganization of some output
###### Step_6th_GroupAtlas_Extract_AP.m - minor reorganization/converting of some output
###### Step_7th_NetworkNaming_Yeo_AP.m - find predominant yeo7/17 overlap and extent of overlap

## 1B) Derive Parcel Properties - Figure 1
###### scripts/derive_netstats/calc_recon_error.m - analysis for figure 1A
###### scripts/derive_spatialprops/group_All_Ks_export2R.m - export for figure 1B
###### scripts/derive_parcels/Toolbox/PBP/PBP_final/PBP_GroCon.m - figure 1C
	
## 1C) Derive Parcel Properties - Figure 2
###### scripts/derive_parcels/Toolbox/PBP/PBP_final/PBP_SSCon.m - for Figure 2A
###### scripts/derive_parcels/Step_2nd_SingleParcellation/Step_9th_1_Visualize_Workbench_AtlasVariability_AP.m	- for MAD calculation
###### scripts/derive_parcels/Toolbox/PBP/PBP_final/PBP_MAD.m - for Figure 2B
###### scripts/derive_spatialprops/gro_level_spatialchange.m - calculate change over space of loadings
###### scripts/derive_parcels/Toolbox/PBP/PBP_final/PBP_SpatChange.m - for figure 2B
###### scripts/derive_spatialprops/aggregate_changeVectors.m - aggregate spatial change values over scales
###### scripts/derive_spatialprops/SpinTest_SpatChange.m - Spin Spatial change maps for correlation null distributions
###### scripts/derive_spatialprops/calc_spinDistribs_MAD.m - Calculate real and permuted MAD-SpatChange correlations - for figure 2C	

## 1D) Extract FC values from individual parcels and .mgh timeseries
###### scripts/derive_netstats/fc_to_csv.m - likely the densest script in the entire project. Designed to take in fake data and spit out corresponding FC matrices + summary columns for sanity check.
###### scripts/derive_netstats/round_master_fcfeats.r - file takes fuckin' forever to load - almost a 10 minute thing without rounding. no need for 12 decimals points or w/e matlab spits out.

# Step 2: Network-level: Age
## 2A) Network-level Generalzied Additive Models - Figure 3 and 5
All within [_Network-level-age.md_](https://github.com/PennLINC/multiscale/blob/master/scripts/analyses/Network-level-age.md)
###### B/w * Age - for figure 3B
###### Age Effect * Transmodality - for figure 3C
###### Age Effect derivative over Age (* Transmodality) - for figure 3D
###### Scale Effect on Age Effect (* Transmodality) - for figure 5C

## 2B)	Cross-scale averaging & vertex-mapping - Figure 3

# Step 3: Network-level : Executive Function
## 3A) Network-level Generalzied Additive Models - Figure 6
All within [_Network-level-ef.md_](https://github.com/PennLINC/multiscale/blob/master/scripts/analyses/Network-level-EF.knit.md)
###### EF Effect * Transmodality - for figure 6C
###### Scale Effect on EF Effect (* Transmodality) - for figure 6D

# Step 4: Network-level : Mediation
## 4A) Network-level Generalzied Additive Models - Figure 7
All within [_Network-level-mediation.md_](https://github.com/PennLINC/multiscale/blob/master/scripts/analyses/Network-level-Mediation.knit.md)
###### Mediation Weight * Transmodality - for figure 6C
###### Scale Effect on Mediation Weight (* Transmodality) - for figure 6D

# Step 5: Vertex-level : Age
# Step 6: Vertex-level : Executive Function
# Step 7: Vertex-level : Scale
# Step 8: Age: Edge-level

analyses - 5 - Nearly pure analytical scripts, written in R, to be executed on matlab outputs

derive_netstats - 2 - Various calculations of network statistics

derive_parcels - 1 - Delineating individualized community structures across scales

derive_percygrads - 4 - Personalized gradients

derive_spatialprops - 3 - Spatial properties of communities

viz - 6 - Visualization scripts for figures outside of .rmd files 

Python environment:
source activate mv_preds


Python environment:
source activate mv_preds
