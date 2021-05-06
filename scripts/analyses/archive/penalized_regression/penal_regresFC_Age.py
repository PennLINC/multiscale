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
subject_preds_A=np.zeros([693,2])
# adding lasso section for sparse features: 10/21/20
subject_preds_AL=np.zeros([693,2])

df_permut=np.loadtxt('/cbica/projects/pinesParcels/results/EffectVecs/forMLpc_permut.csv',delimiter=',')

# Subject b.w. features	
filename='/cbica/projects/pinesParcels/results/EffectVecs/AgeOnly'
data_A=np.loadtxt(filename,delimiter=',')
# Divide to predict var of int columns
Featvecs_A=data_A[:,:-1]
# extract EF variable from last column
varofintA=data_A[:,-1]
#varofint_permut=masterdf_permut[:,varofintnum]
# set alphas for gcv
#alphas = np.exp2(np.arange(-6,16,.3))
# fewer alphas for lasso to run thru
alphas = np.exp2(np.arange(16)-10)
# set subject indices for recoring train test splits
indices = range(693)

# outcome predictions will be in these 2d arrays (finally back to 2d!)
# needs to be 12 x 3, 12 rows for each split and each column for each feature vector
all_preds=np.empty([100,2])
#all_permut_preds=np.empty([12,1])
all_preds_alphas=np.empty([100,2])
#all_permut_preds_alphas=np.empty([12,1])
# feature weights, lasso weights added 10/21/20
featureWeights_A=np.empty([100,data_A.shape[1]-1])
featureWeights_AL=np.empty([100,data_A.shape[1]-1])
for split in range(0,100):
# for a few different train and test splits
	# Train and test split from data frame
	xtrain_A,xtest_A,ytrain_A,ytest_A,indices_train_A,indices_test_A=train_test_split(Featvecs_A,varofintA,indices,test_size=0.33,random_state=(split))
	# same for permuted data
	#xtrain_p,xtest_p,ytrain_p,ytest_p=train_test_split(topogvecs,varofint_permut,test_size=0.33,random_state=(split))
	# outcome vector for this split, different vec for permuted and real data
	r2_vec_split_A=[]
	r2_vec_split_AL=[]
	#r2_vec_split_permut=[]
	# fit model with gcv
	lm_A = sklearn.linear_model.RidgeCV(alphas=alphas, store_cv_values=True).fit(xtrain_A,ytrain_A)
	#lm_AL = sklearn.linear_model.LassoCV(alphas=alphas,max_iter=100000).fit(xtrain_A,ytrain_A)
	# same for permuted
	#lm_p = sklearn.linear_model.RidgeCV(alphas=alphas, store_cv_values=True).fit(xtrain_p,ytrain_p)
	# set prediction alpha to best performing alpha in training set
	alpha_A=lm_A.alpha_
	#alpha_AL=lm_AL.alpha_
	# save regularization weightings for this split
	all_preds_alphas[split,0]=alpha_A
	#all_preds_alphas[split,1]=alpha_AL
	#alpha_p=lm_p.alpha_
	#all_permut_preds_alphas[split,:]=alpha_p
	# store vector of feature weights for cortical surface projections
	featureWeights_A[split,:]=lm_A.coef_
	#featureWeights_AL[split,:]=lm_AL.coef_
	# get predicted Age values
	pred_A=lm_A.predict(xtest_A)
	#pred_AL=lm_AL.predict(xtest_A)
	# add predicted EF to indices this iteration was not trained on, add another number 
	subject_preds_A[indices_test_A,0]=subject_preds_A[indices_test_A,0]+pred_A
	subject_preds_A[indices_test_A,1]=subject_preds_A[indices_test_A,1]+1
	#subject_preds_AL[indices_test_A,0]=subject_preds_AL[indices_test_A,0]+pred_AL
	#subject_preds_AL[indices_test_A,1]=subject_preds_AL[indices_test_A,1]+1
	# test prediction on left out sample
	pred_obs_r2_A = sklearn.linear_model.Ridge(alpha=alpha_A).fit(xtrain_A,ytrain_A).score(xtest_A,ytest_A)
	#pred_obs_r2_AL = sklearn.linear_model.Lasso(alpha=alpha_AL,max_iter=100000).fit(xtrain_A,ytrain_A).score(xtest_A,ytest_A)
	# parallel prediction for permuted data ######
	#pred_obs_r2_permut = sklearn.linear_model.Ridge(alpha=alpha_p).fit(xtrain_p,ytrain_p).score(xtest_p,ytest_p)
	# stack the 5 predictions vertically to be averaged across samples splits
	all_preds[split,0]=pred_obs_r2_A
	#all_preds[split,1]=pred_obs_r2_AL
	#all_permut_preds[split,:]=pred_obs_r2_permut	

# mean age predictions
mean_preds_A=np.average(all_preds[:,0])
#mean_preds_AL=np.average(all_preds[:,1])
#mean_preds_permut=np.average(all_permut_preds[:])
# mean alphas
mean_alphas_A=np.average(all_preds_alphas[:,0])
#mean_alphas_AL=np.average(all_preds_alphas[:,1])
#mean_alphas_permut=np.average(all_permut_preds_alphas[:])
# mean feature weights
mean_featureWeights_A=np.average(featureWeights_A,axis=0)
#mean_featureWeights_AL=np.average(featureWeights_AL,axis=0)
##mean_permut_preds.append(np.average(all_rot_preds[:,0]))
# mean EF predictions
#mean_louv_preds.append(np.average(all_louv_preds[:,1]))
#mean_rot_preds.append(np.average(all_rot_preds[:,1]))
# throw em in (p-1 because there's no part_0.mat)
summary_preds[0,0]=mean_preds_A
summary_preds[0,1]=mean_alphas_A
#summary_preds[1,0]=mean_preds_AL
#summary_preds[1,1]=mean_alphas_AL
#summary_topo_preds_permut[K-2,1]=mean_preds_permut
#summary_topo_preds_permut[K-2,2]=mean_alphas_permut
#summary_topo_preds_permut[K-2,1]=mean_preds_permut
print("Unpermuted out-of-sample prediction - age:" + str(mean_preds_A))
#print("Unpermuted out-of-sample prediction - age Lasso:" + str(mean_preds_AL))
#print("Permuted prediction" + str(mean_preds_permut))
print("Average Optimal Regularization Weighting - age:" + str(mean_alphas_A))
#print("Average Optimal Regularization Weighting - age Lasso:" + str(mean_alphas_AL))
#print("Permuted Average Optimal Regularization Weighting" + str(mean_alphas_permut))	
featureweightsFN='/cbica/projects/pinesParcels/data/aggregated_data/FeatureWeights_A.csv'
np.savetxt(featureweightsFN,mean_featureWeights_A,delimiter=",")
#featureweightsFN='/cbica/projects/pinesParcels/data/aggregated_data/FeatureWeights_AL.csv'
#np.savetxt(featureweightsFN,mean_featureWeights_AL,delimiter=",")
# save predicted subject info
subjpredsFN='/cbica/projects/pinesParcels/data/aggregated_data/SubjPreds_A.csv'
np.savetxt(subjpredsFN,subject_preds_A,delimiter=",")
#subjpredsFN='/cbica/projects/pinesParcels/data/aggregated_data/SubjPreds_AL.csv'
#np.savetxt(subjpredsFN,subject_preds_AL,delimiter=",")
#np.savetxt('topo_preds_ridge',summary_topo_preds)
#np.savetxt('master_rot_preds_ridge',master_rot_preds)

	
	

