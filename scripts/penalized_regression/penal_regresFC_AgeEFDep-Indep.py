## imports ##
import scipy
import scipy.io as sio
from os.path import dirname, join as pjoin
import numpy as np
import sklearn 
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.linear_model import RidgeCV
from sklearn.linear_model import Ridge
from sklearn.metrics import mean_squared_error
from sklearn.metrics import r2_score
import sys


### Age mitigated and Age facilitated EF b/w feature ridge prediction comparisons

# we will want to store out-of-sample prediction, and alpha selected for each scale, so 3 columns
summary_preds=np.empty([4,2])
# summary_topo_preds_permut=np.empty([2,2])

# need a different, subject-level prediction DF so we can unpack predicted EF in R
# first column is additive predicted EF, second column is number of times it was added
subject_preds_AI=np.zeros([693,2])
subject_preds_AD=np.zeros([693,2])
# adding lasso section for sparse features: 10/21/20
subject_preds_AIL=np.zeros([693,2])
subject_preds_ADL=np.zeros([693,2])

df_permut=np.loadtxt('/cbica/projects/pinesParcels/results/EffectVecs/forMLpc_permut.csv',delimiter=',')

# Subject b.w. features	
filename='/cbica/projects/pinesParcels/results/EffectVecs/AgeIndepEF'
data_AI=np.loadtxt(filename,delimiter=',')
filename='/cbica/projects/pinesParcels/results/EffectVecs/AgeDepEF'
data_AD=np.loadtxt(filename,delimiter=',')
# Divide to predict var of int columns
Featvecs_AI=data_AI[:,:-1]
Featvecs_AD=data_AD[:,:-1]
# extract EF variable from last column
varofintAI=data_AI[:,-1]
varofintAD=data_AD[:,-1]
#varofint_permut=masterdf_permut[:,varofintnum]
# set alphas for gcv
#alphas = np.exp2(np.arange(-6,16,.3))
# fewer alphas for lasso to run thru
alphas = np.exp2(np.arange(16)-10)
# set subject indices for recoring train test splits
indices = range(693)

# outcome predictions will be in these 2d arrays (finally back to 2d!)
# needs to be 12 x 3, 12 rows for each split and each column for each feature vector
all_preds=np.empty([100,4])
#all_permut_preds=np.empty([12,1])
all_preds_alphas=np.empty([100,4])
#all_permut_preds_alphas=np.empty([12,1])
# feature weights, lasso weights added 10/21/20
featureWeights_AI=np.empty([100,data_AI.shape[1]-1])
featureWeights_AD=np.empty([100,data_AD.shape[1]-1])
featureWeights_AIL=np.empty([100,data_AI.shape[1]-1])
featureWeights_ADL=np.empty([100,data_AD.shape[1]-1])
for split in range(0,100):
# for a few different train and test splits
	# Train and test split from data frame
	xtrain_AI,xtest_AI,ytrain_AI,ytest_AI,indices_train_AI,indices_test_AI=train_test_split(Featvecs_AI,varofintAI,indices,test_size=0.33,random_state=(split))
	xtrain_AD,xtest_AD,ytrain_AD,ytest_AD,indices_train_AD,indices_test_AD=train_test_split(Featvecs_AD,varofintAD,indices,test_size=0.33,random_state=(split))
	# same for permuted data
	#xtrain_p,xtest_p,ytrain_p,ytest_p=train_test_split(topogvecs,varofint_permut,test_size=0.33,random_state=(split))
	# outcome vector for this split, different vec for permuted and real data
	r2_vec_split_AI=[]
	r2_vec_split_AD=[]
	r2_vec_split_AIL=[]
	r2_vec_split_ADL=[]
	#r2_vec_split_permut=[]
	# fit model with gcv
	lm_AD = sklearn.linear_model.RidgeCV(alphas=alphas, store_cv_values=True).fit(xtrain_AD,ytrain_AD)
	lm_AI = sklearn.linear_model.RidgeCV(alphas=alphas, store_cv_values=True).fit(xtrain_AI,ytrain_AI)
	lm_ADL = sklearn.linear_model.LassoCV(alphas=alphas).fit(xtrain_AD,ytrain_AD)
	lm_AIL = sklearn.linear_model.LassoCV(alphas=alphas).fit(xtrain_AI,ytrain_AI)
	# same for permuted
	#lm_p = sklearn.linear_model.RidgeCV(alphas=alphas, store_cv_values=True).fit(xtrain_p,ytrain_p)
	# set prediction alpha to best performing alpha in training set
	alpha_AD=lm_AD.alpha_
	alpha_AI=lm_AI.alpha_
	alpha_ADL=lm_ADL.alpha_
	alpha_AIL=lm_AIL.alpha_
	# save regularization weightings for this split
	all_preds_alphas[split,0]=alpha_AD
	all_preds_alphas[split,1]=alpha_AI
	all_preds_alphas[split,2]=alpha_ADL
	all_preds_alphas[split,3]=alpha_AIL
	#alpha_p=lm_p.alpha_
	#all_permut_preds_alphas[split,:]=alpha_p
	# store vector of feature weights for cortical surface projections
	featureWeights_AD[split,:]=lm_AD.coef_
	featureWeights_AI[split,:]=lm_AI.coef_
	featureWeights_ADL[split,:]=lm_ADL.coef_
	featureWeights_AIL[split,:]=lm_AIL.coef_
	# get predicted EF values
	predEF_AD=lm_AD.predict(xtest_AD)
	predEF_AI=lm_AI.predict(xtest_AI)
	predEF_ADL=lm_ADL.predict(xtest_AD)
	predEF_AIL=lm_AIL.predict(xtest_AI)
	# add predicted EF to indices this iteration was not trained on, add another number 
	subject_preds_AD[indices_test_AD,0]=subject_preds_AD[indices_test_AD,0]+predEF_AD
	subject_preds_AI[indices_test_AI,0]=subject_preds_AI[indices_test_AI,0]+predEF_AI
	subject_preds_AD[indices_test_AD,1]=subject_preds_AD[indices_test_AD,1]+1
	subject_preds_AI[indices_test_AI,1]=subject_preds_AI[indices_test_AI,1]+1
	subject_preds_ADL[indices_test_AD,0]=subject_preds_ADL[indices_test_AD,0]+predEF_ADL
	subject_preds_AIL[indices_test_AI,0]=subject_preds_AIL[indices_test_AI,0]+predEF_AIL
	subject_preds_ADL[indices_test_AD,1]=subject_preds_ADL[indices_test_AD,1]+1
	subject_preds_AIL[indices_test_AI,1]=subject_preds_AIL[indices_test_AI,1]+1
	# test prediction on left out sample
	pred_obs_r2_AD = sklearn.linear_model.Ridge(alpha=alpha_AD).fit(xtrain_AD,ytrain_AD).score(xtest_AD,ytest_AD)
	pred_obs_r2_AI = sklearn.linear_model.Ridge(alpha=alpha_AI).fit(xtrain_AI,ytrain_AI).score(xtest_AI,ytest_AI)
	pred_obs_r2_ADL = sklearn.linear_model.Lasso(alpha=alpha_ADL).fit(xtrain_AD,ytrain_AD).score(xtest_AD,ytest_AD)
	pred_obs_r2_AIL = sklearn.linear_model.Lasso(alpha=alpha_AIL).fit(xtrain_AI,ytrain_AI).score(xtest_AI,ytest_AI)
	# parallel prediction for permuted data ######
	#pred_obs_r2_permut = sklearn.linear_model.Ridge(alpha=alpha_p).fit(xtrain_p,ytrain_p).score(xtest_p,ytest_p)
	# stack the 5 predictions vertically to be averaged across samples splits
	all_preds[split,0]=pred_obs_r2_AD
	all_preds[split,1]=pred_obs_r2_AI
	all_preds[split,2]=pred_obs_r2_ADL
	all_preds[split,3]=pred_obs_r2_AIL
	#all_permut_preds[split,:]=pred_obs_r2_permut	

# mean age predictions
mean_preds_AD=np.average(all_preds[:,0])
mean_preds_AI=np.average(all_preds[:,1])
mean_preds_ADL=np.average(all_preds[:,2])
mean_preds_AIL=np.average(all_preds[:,3])
#mean_preds_permut=np.average(all_permut_preds[:])
# mean alphas
mean_alphas_AD=np.average(all_preds_alphas[:,0])
mean_alphas_AI=np.average(all_preds_alphas[:,1])
mean_alphas_ADL=np.average(all_preds_alphas[:,2])
mean_alphas_AIL=np.average(all_preds_alphas[:,3])
#mean_alphas_permut=np.average(all_permut_preds_alphas[:])
# mean feature weights
mean_featureWeights_AD=np.average(featureWeights_AD,axis=0)
mean_featureWeights_AI=np.average(featureWeights_AI,axis=0)
mean_featureWeights_ADL=np.average(featureWeights_ADL,axis=0)
mean_featureWeights_AIL=np.average(featureWeights_AIL,axis=0)
##mean_permut_preds.append(np.average(all_rot_preds[:,0]))
# mean EF predictions
#mean_louv_preds.append(np.average(all_louv_preds[:,1]))
#mean_rot_preds.append(np.average(all_rot_preds[:,1]))
# throw em in (p-1 because there's no part_0.mat)
summary_preds[0,0]=mean_preds_AD
summary_preds[0,1]=mean_alphas_AD
summary_preds[1,0]=mean_preds_AI
summary_preds[1,1]=mean_alphas_AI
summary_preds[2,0]=mean_preds_ADL
summary_preds[2,1]=mean_alphas_ADL
summary_preds[3,0]=mean_preds_AIL
summary_preds[3,1]=mean_alphas_AIL
#summary_topo_preds_permut[K-2,1]=mean_preds_permut
#summary_topo_preds_permut[K-2,2]=mean_alphas_permut
#summary_topo_preds_permut[K-2,1]=mean_preds_permut
print("Unpermuted out-of-sample prediction - age Dep.:" + str(mean_preds_AD))
print("Unpermuted out-of-sample prediction - age Indep.:" + str(mean_preds_AI))
print("Unpermuted out-of-sample prediction - age Dep. Lasso:" + str(mean_preds_ADL))
print("Unpermuted out-of-sample prediction - age Indep. Lasso:" + str(mean_preds_AIL))
#print("Permuted prediction" + str(mean_preds_permut))
print("Average Optimal Regularization Weighting - age Dep. only:" + str(mean_alphas_AD))
print("Average Optimal Regularization Weighting - age Indep. only:" + str(mean_alphas_AI))
print("Average Optimal Regularization Weighting - age Dep. only Lasso:" + str(mean_alphas_ADL))
print("Average Optimal Regularization Weighting - age Indep. only Lasso:" + str(mean_alphas_AIL))
#print("Permuted Average Optimal Regularization Weighting" + str(mean_alphas_permut))	
featureweightsFN='/cbica/projects/pinesParcels/data/aggregated_data/FeatureWeights_AD.csv'
np.savetxt(featureweightsFN,mean_featureWeights_AD,delimiter=",")
featureweightsFN='/cbica/projects/pinesParcels/data/aggregated_data/FeatureWeights_AI.csv'
np.savetxt(featureweightsFN,mean_featureWeights_AI,delimiter=",")
featureweightsFN='/cbica/projects/pinesParcels/data/aggregated_data/FeatureWeights_ADL.csv'
np.savetxt(featureweightsFN,mean_featureWeights_ADL,delimiter=",")
featureweightsFN='/cbica/projects/pinesParcels/data/aggregated_data/FeatureWeights_AIL.csv'
np.savetxt(featureweightsFN,mean_featureWeights_AIL,delimiter=",")
# save predicted subject info
subjpredsFN='/cbica/projects/pinesParcels/data/aggregated_data/SubjPreds_AD.csv'
np.savetxt(subjpredsFN,subject_preds_AD,delimiter=",")
subjpredsFN='/cbica/projects/pinesParcels/data/aggregated_data/SubjPreds_AI.csv'
np.savetxt(subjpredsFN,subject_preds_AI,delimiter=",")
subjpredsFN='/cbica/projects/pinesParcels/data/aggregated_data/SubjPreds_ADL.csv'
np.savetxt(subjpredsFN,subject_preds_ADL,delimiter=",")
subjpredsFN='/cbica/projects/pinesParcels/data/aggregated_data/SubjPreds_AIL.csv'
np.savetxt(subjpredsFN,subject_preds_AIL,delimiter=",")
#np.savetxt('topo_preds_ridge',summary_topo_preds)
#np.savetxt('master_rot_preds_ridge',master_rot_preds)

	
	

