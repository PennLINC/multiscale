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
import h5py
import pandas as pd
import sys


### Age mitigated and Age facilitated EF b/w feature ridge prediction comparisons

# we will want to store out-of-sample prediction, and alpha selected for each scale, so 3 columns
summary_preds=np.empty([3,2])
# summary_topo_preds_permut=np.empty([2,2])

# need a different, subject-level prediction DF so we can unpack predicted EF in R
# first column is additive predicted EF, second column is number of times it was added
subject_preds=np.zeros([693,2])
subject_preds_agF=np.zeros([693,2])
subject_preds_agM=np.zeros([693,2])

# bring in the variables we care about (bblid,age,motion,sex)
df=np.loadtxt('/cbica/projects/pinesParcels/results/EffectVecs/forMLpc.csv',delimiter=',')
df_permut=np.loadtxt('/cbica/projects/pinesParcels/results/EffectVecs/forMLpc_permut.csv',delimiter=',')

# Subject b.w. features	
filename='/cbica/projects/pinesParcels/results/EffectVecs/AgeFacilAndMitigFeats'
data=np.loadtxt(filename,delimiter=',')
filename='/cbica/projects/pinesParcels/results/EffectVecs/AgeFacilFeats'
data_agF=np.loadtxt(filename,delimiter=',')
filename='/cbica/projects/pinesParcels/results/EffectVecs/AgeMitigFeats'
data_agM=np.loadtxt(filename,delimiter=',')

# Divide to predict var of int columns
Featvecs=data[:,0:data.shape[1]-1]
Featvecs_agF=data_agF[:,0:data_agF.shape[1]-1]
Featvecs_agM=data_agM[:,0:data_agM.shape[1]-1]

# extract EF variable from last column (-1 because python)
varofint=data[:,data.shape[1]-1]
#varofint_permut=masterdf_permut[:,varofintnum]
# set alphas for gcv
# use Zaixu's alpha range
alphas = np.exp2(np.arange(16) - 10)
# set subject indices for recoring train test splits
indices = range(693)

# outcome predictions will be in these 2d arrays (finally back to 2d!)
# needs to be 12 x 3, 12 rows for each split and each column for each feature vector
all_preds=np.empty([100,3])
#all_permut_preds=np.empty([12,1])
all_preds_alphas=np.empty([100,3])
#all_permut_preds_alphas=np.empty([12,1])

# feature weights
featureWeights=np.empty([100,data.shape[1]-1])
featureWeights_agF=np.empty([100,data_agF.shape[1]-1])
featureWeights_agM=np.empty([100,data_agM.shape[1]-1])

for split in range(0,100):
# for a few different train and test splits
	# Train and test split from data frame
	xtrain,xtest,ytrain,ytest,indices_train,indices_test=train_test_split(Featvecs,varofint,indices,test_size=0.33,random_state=(split))
	xtrain_agF,xtest_agF,ytrain_agF,ytest_agF,indices_train_agF,indices_test_agF=train_test_split(Featvecs_agF,varofint,indices,test_size=0.33,random_state=(split))
	xtrain_agM,xtest_agM,ytrain_agM,ytest_agM,indices_train_agM,indices_test_agM=train_test_split(Featvecs_agM,varofint,indices,test_size=0.33,random_state=(split))
	# same for permuted data
	#xtrain_p,xtest_p,ytrain_p,ytest_p=train_test_split(topogvecs,varofint_permut,test_size=0.33,random_state=(split))
	# outcome vector for this split, different vec for permuted and real data
	r2_vec_split=[]
	r2_vec_split_agF=[]
	r2_vec_split_agM=[]
	#r2_vec_split_permut=[]
	# fit model with gcv
	lm = sklearn.linear_model.RidgeCV(alphas=alphas, store_cv_values=True).fit(xtrain,ytrain)
	lm_agF = sklearn.linear_model.RidgeCV(alphas=alphas, store_cv_values=True).fit(xtrain_agF,ytrain_agF)
	lm_agM = sklearn.linear_model.RidgeCV(alphas=alphas, store_cv_values=True).fit(xtrain_agM,ytrain_agM)
	# same for permuted
	#lm_p = sklearn.linear_model.RidgeCV(alphas=alphas, store_cv_values=True).fit(xtrain_p,ytrain_p)
	# set prediction alpha to best performing alpha in training set
	alpha=lm.alpha_
	alpha_agF=lm_agF.alpha_
	alpha_agM=lm_agM.alpha_
	# save regularization weightings for this split
	all_preds_alphas[split,0]=alpha
	all_preds_alphas[split,1]=alpha_agF
	all_preds_alphas[split,2]=alpha_agM
	#alpha_p=lm_p.alpha_
	#all_permut_preds_alphas[split,:]=alpha_p
	# store vector of feature weights for cortical surface projections
	featureWeights[split,:]=lm.coef_
	featureWeights_agF[split,:]=lm_agF.coef_
	featureWeights_agM[split,:]=lm_agM.coef_
	# get predicted EF values
	predEF=lm.predict(xtest)
	predEF_agF=lm_agF.predict(xtest_agF)
	predEF_agM=lm_agM.predict(xtest_agM)
	# add predicted EF to indices this iteration was not trained on, add another number 
	subject_preds[indices_test,0]=subject_preds[indices_test,0]+predEF
	subject_preds_agF[indices_test_agF,0]=subject_preds_agF[indices_test_agF,0]+predEF_agF
	subject_preds_agM[indices_test_agM,0]=subject_preds_agM[indices_test_agM,0]+predEF_agM
	subject_preds[indices_test,1]=subject_preds[indices_test,1]+1
	subject_preds_agF[indices_test_agF,1]=subject_preds_agF[indices_test_agF,1]+1
	subject_preds_agM[indices_test_agM,1]=subject_preds_agM[indices_test_agM,1]+1
	
	# test prediction on left out sample
	pred_obs_r2 = sklearn.linear_model.Ridge(alpha=alpha).fit(xtrain,ytrain).score(xtest,ytest)
	pred_obs_r2_agF = sklearn.linear_model.Ridge(alpha=alpha_agF).fit(xtrain_agF,ytrain_agF).score(xtest_agF,ytest_agF)
	pred_obs_r2_agM = sklearn.linear_model.Ridge(alpha=alpha_agM).fit(xtrain_agM,ytrain_agM).score(xtest_agM,ytest_agM)
	# parallel prediction for permuted data ######
	#pred_obs_r2_permut = sklearn.linear_model.Ridge(alpha=alpha_p).fit(xtrain_p,ytrain_p).score(xtest_p,ytest_p)
	# stack the 5 predictions vertically to be averaged across samples splits
	all_preds[split,0]=pred_obs_r2
	all_preds[split,1]=pred_obs_r2_agF
	all_preds[split,2]=pred_obs_r2_agM
	#all_permut_preds[split,:]=pred_obs_r2_permut	
	
# mean age predictions
mean_preds=np.average(all_preds[:,0])
mean_preds_agF=np.average(all_preds[:,1])
mean_preds_agM=np.average(all_preds[:,2])
#mean_preds_permut=np.average(all_permut_preds[:])
# mean alphas
mean_alphas=np.average(all_preds_alphas[:,0])
mean_alphas_agF=np.average(all_preds_alphas[:,1])
mean_alphas_agM=np.average(all_preds_alphas[:,2])
#mean_alphas_permut=np.average(all_permut_preds_alphas[:])

# mean feature weights
mean_featureWeights=np.average(featureWeights,axis=0)
mean_featureWeights_agF=np.average(featureWeights_agF,axis=0)
mean_featureWeights_agM=np.average(featureWeights_agM,axis=0)

##mean_permut_preds.append(np.average(all_rot_preds[:,0]))
# mean EF predictions
#mean_louv_preds.append(np.average(all_louv_preds[:,1]))
#mean_rot_preds.append(np.average(all_rot_preds[:,1]))
# throw em in (p-1 because there's no part_0.mat)
summary_preds[0,0]=mean_preds
summary_preds[0,1]=mean_alphas
summary_preds[1,0]=mean_preds_agF
summary_preds[1,1]=mean_alphas_agF
summary_preds[2,0]=mean_preds_agM

#summary_topo_preds_permut[K-2,1]=mean_preds_permut
#summary_topo_preds_permut[K-2,2]=mean_alphas_permut
#summary_topo_preds_permut[K-2,1]=mean_preds_permut
print("Unpermuted out-of-sample prediction:" + str(mean_preds))
print("Unpermuted out-of-sample prediction - age facil. only:" + str(mean_preds_agF))
print("Unpermuted out-of-sample prediction - age mitig. only:" + str(mean_preds_agM))
#print("Permuted prediction" + str(mean_preds_permut))
print("Average Optimal Regularization Weighting" + str(mean_alphas))
print("Average Optimal Regularization Weighting - age facil. only:" + str(mean_alphas_agF))
print("Average Optimal Regularization Weighting - age mitig. only:" + str(mean_alphas_agM))
#print("Permuted Average Optimal Regularization Weighting" + str(mean_alphas_permut))	
featureweightsFN='/cbica/projects/pinesParcels/data/aggregated_data/FeatureWeights_agFagM.csv'
np.savetxt(featureweightsFN,mean_featureWeights,delimiter=",")
featureweightsFN='/cbica/projects/pinesParcels/data/aggregated_data/FeatureWeights_agF.csv'
np.savetxt(featureweightsFN,mean_featureWeights_agF,delimiter=",")
featureweightsFN='/cbica/projects/pinesParcels/data/aggregated_data/FeatureWeights_agM.csv'
np.savetxt(featureweightsFN,mean_featureWeights_agM,delimiter=",")
# save predicted subject info
subjpredsFN='/cbica/projects/pinesParcels/data/aggregated_data/SubjPreds_agFagM.csv'
np.savetxt(subjpredsFN,subject_preds,delimiter=",")
subjpredsFN='/cbica/projects/pinesParcels/data/aggregated_data/SubjPreds_agF.csv'
np.savetxt(subjpredsFN,subject_preds_agF,delimiter=",")
subjpredsFN='/cbica/projects/pinesParcels/data/aggregated_data/SubjPreds_agM.csv'
np.savetxt(subjpredsFN,subject_preds_agM,delimiter=",")
#np.savetxt('topo_preds_ridge',summary_topo_preds)
#np.savetxt('master_rot_preds_ridge',master_rot_preds)

	
	
		
			

			

	







