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
summary_preds=np.empty([2,2])
# summary_topo_preds_permut=np.empty([2,2])

# need a different, subject-level prediction DF so we can unpack predicted EF in R
# first column is additive predicted EF, second column is number of times it was added
subject_preds17=np.zeros([693,2])
subject_predsMS=np.zeros([693,2])

# Subject b.w. features	
filename='/cbica/projects/pinesParcels/results/EffectVecs/edgesAt17_EF'
data17=np.loadtxt(filename,delimiter=',')
filename='/cbica/projects/pinesParcels/results/EffectVecs/edges_EF'
dataMS=np.loadtxt(filename,delimiter=',')

# Divide to predict var of int columns
Featvecs17=data17[:,0:data17.shape[1]-1]
FeatvecsMS=dataMS[:,0:dataMS.shape[1]-1]

# extract EF variable from last column (-1 because python)
varofint17=data17[:,data17.shape[1]-1]
varofintMS=dataMS[:,dataMS.shape[1]-1]
# set alphas for gcv
# use Zaixu's alpha range
alphas = np.exp2(np.arange(16) - 10)
# set subject indices for recoring train test splits
indices = range(693)

# outcome predictions will be in these 2d arrays (finally back to 2d!)
# needs to be 12 x 2, 12 rows for each split and each column for each feature vector
all_preds=np.empty([100,2])
all_preds_alphas=np.empty([100,2])

# feature weights
featureWeights17=np.empty([100,data17.shape[1]-1])
featureWeightsMS=np.empty([100,dataMS.shape[1]-1])

for split in range(0,100):
# for a few different train and test splits
	# Train and test split from data frame
	xtrain17,xtest17,ytrain17,ytest17,indices_train17,indices_test17=train_test_split(Featvecs17,varofint17,indices,test_size=0.33,random_state=(split))
	xtrainMS,xtestMS,ytrainMS,ytestMS,indices_trainMS,indices_testMS=train_test_split(FeatvecsMS,varofintMS,indices,test_size=0.33,random_state=(split))
	# outcome vector for this split, different vec for permuted and real data
	r2_vec_split17=[]
	r2_vec_splitMS=[]
	# fit model with gcv
	lm17 = sklearn.linear_model.RidgeCV(alphas=alphas, store_cv_values=True).fit(xtrain17,ytrain17)
	lmMS = sklearn.linear_model.RidgeCV(alphas=alphas, store_cv_values=True).fit(xtrainMS,ytrainMS)
	# set prediction alpha to best performing alpha in training set
	alpha17=lm17.alpha_
	alphaMS=lmMS.alpha_
	# save regularization weightings for this split
	all_preds_alphas[split,0]=alpha17
	all_preds_alphas[split,1]=alphaMS
	# store vector of feature weights for cortical surface projections
	featureWeights17[split,:]=lm17.coef_
	featureWeightsMS[split,:]=lmMS.coef_
	# get predicted EF values
	predEF17=lm17.predict(xtest17)
	predEFMS=lmMS.predict(xtestMS)
	# add predicted EF to indices this iteration was not trained on, add another number 
	subject_preds17[indices_test17,0]=subject_preds17[indices_test17,0]+predEF17
	subject_predsMS[indices_testMS,0]=subject_predsMS[indices_testMS,0]+predEFMS
	subject_preds17[indices_test17,1]=subject_preds17[indices_test17,1]+1
	subject_predsMS[indices_testMS,1]=subject_predsMS[indices_testMS,1]+1
	# test prediction on left out sample
	pred_obs_r217 = sklearn.linear_model.Ridge(alpha=alpha17).fit(xtrain17,ytrain17).score(xtest17,ytest17)
	pred_obs_r2MS = sklearn.linear_model.Ridge(alpha=alphaMS).fit(xtrainMS,ytrainMS).score(xtestMS,ytestMS)
	# stack the predictions vertically to be averaged across samples splits
	all_preds[split,0]=pred_obs_r217
	all_preds[split,1]=pred_obs_r2MS
	
# mean age predictions
mean_preds17=np.average(all_preds[:,0])
mean_predsMS=np.average(all_preds[:,1])
#mean_preds_permut=np.average(all_permut_preds[:])
# mean alphas
mean_alphas17=np.average(all_preds_alphas[:,0])
mean_alphasMS=np.average(all_preds_alphas[:,1])
# mean feature weights
mean_featureWeights17=np.average(featureWeights17,axis=0)
mean_featureWeightsMS=np.average(featureWeightsMS,axis=0)
# mean EF predictions
summary_preds[0,0]=mean_preds17
summary_preds[0,1]=mean_alphas17
summary_preds[1,0]=mean_predsMS
summary_preds[1,1]=mean_alphasMS
print("Unpermuted out-of-sample prediction @ K=17:" + str(mean_preds17))
print("Unpermuted out-of-sample prediction: All edges:" + str(mean_predsMS))
print("Average Optimal Regularization Weighting @ K=17" + str(mean_alphas17))
print("Average Optimal Regularization Weighting: All edges:" + str(mean_alphasMS))
featureweightsFN='/cbica/projects/pinesParcels/data/aggregated_data/FeatureWeights17.csv'
np.savetxt(featureweightsFN,mean_featureWeights17,delimiter=",")
featureweightsFN='/cbica/projects/pinesParcels/data/aggregated_data/FeatureWeightsMS.csv'
np.savetxt(featureweightsFN,mean_featureWeightsMS,delimiter=",")
# save predicted subject info
subjpredsFN='/cbica/projects/pinesParcels/data/aggregated_data/SubjPreds_17.csv'
np.savetxt(subjpredsFN,subject_preds17,delimiter=",")
subjpredsFN='/cbica/projects/pinesParcels/data/aggregated_data/SubjPreds_MS.csv'
np.savetxt(subjpredsFN,subject_predsMS,delimiter=",")

	
	
		
			

			

	







