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

### paramters that apply across all loop iterations
# set alphas for gcv
# use this alpha range
alphas = np.exp2(np.arange(16) - 10)
# vector for variable edge numbers
edgeRange = range(30,1000,30)
# arrays for storing iterative lm features
SR_preds=np.empty([100,len(edgeRange)])
LR_preds=np.empty([100,len(edgeRange)])
AR_preds=np.empty([100,len(edgeRange)])
SR_alphas=np.empty([100,len(edgeRange)])
LR_alphas=np.empty([100,len(edgeRange)])
AR_alphas=np.empty([100,len(edgeRange)])
# for all scales, and using full feature matrix as "scale 31" for convenience
for edgeNum in edgeRange:
	# print index in edge range
	print(edgeRange.index(edgeNum))
	# Subject b.w. features	
	SRfilename='/cbica/projects/pinesParcels/results/EffectVecs/SR' + str(edgeNum) + '_for_bw_RRfc.csv'
	LRfilename='/cbica/projects/pinesParcels/results/EffectVecs/LR' + str(edgeNum) + '_for_bw_RRfc.csv'
	ARfilename='/cbica/projects/pinesParcels/results/EffectVecs/AR' + str(edgeNum) + '_for_bw_RRfc.csv'
	dataSR=np.loadtxt(SRfilename,delimiter=',')
	dataLR=np.loadtxt(LRfilename,delimiter=',')
	dataAR=np.loadtxt(ARfilename,delimiter=',')
	# Divide to predict var of int columns
	SRFeatvecs=dataSR[:,2:(len(dataSR))]
	LRFeatvecs=dataLR[:,2:(len(dataLR))]
	ARFeatvecs=dataAR[:,2:(len(dataAR))]
	# extract Age variable from 1st column
	SRvarofint=dataSR[:,0]
	LRvarofint=dataLR[:,0]
	ARvarofint=dataAR[:,0]
	for split in range(0,100):
		# for a few different train and test splits
		# Train and test split from data frame
		SRxtrain,SRxtest,SRytrain,SRytest=train_test_split(SRFeatvecs,SRvarofint,test_size=0.33,random_state=(split))
		LRxtrain,LRxtest,LRytrain,LRytest=train_test_split(LRFeatvecs,LRvarofint,test_size=0.33,random_state=(split))
		ARxtrain,ARxtest,ARytrain,ARytest=train_test_split(ARFeatvecs,ARvarofint,test_size=0.33,random_state=(split))
		# fit model with gcv # false intercept bc it is centered now
		SRlm = sklearn.linear_model.RidgeCV(alphas=alphas,store_cv_values=True).fit(SRxtrain,SRytrain)
		LRlm = sklearn.linear_model.RidgeCV(alphas=alphas,store_cv_values=True).fit(LRxtrain,LRytrain)
		ARlm = sklearn.linear_model.RidgeCV(alphas=alphas,store_cv_values=True).fit(ARxtrain,ARytrain)
		# set prediction alpha to best performing alpha in training set
		SRalpha=SRlm.alpha_
		LRalpha=LRlm.alpha_
		ARalpha=ARlm.alpha_
		# test prediction on left out sample
		SRpred_obs_r2 = sklearn.linear_model.Ridge(alpha=SRalpha).fit(SRxtrain,SRytrain).score(SRxtest,SRytest)
		LRpred_obs_r2 = sklearn.linear_model.Ridge(alpha=LRalpha).fit(LRxtrain,LRytrain).score(LRxtest,LRytest)
		ARpred_obs_r2 = sklearn.linear_model.Ridge(alpha=ARalpha).fit(ARxtrain,ARytrain).score(ARxtest,ARytest)
		# stack the predictions vertically to be averaged across samples splits
		SR_preds[split,edgeRange.index(edgeNum)]=SRpred_obs_r2
		SR_alphas[split,edgeRange.index(edgeNum)]=SRalpha
		LR_preds[split,edgeRange.index(edgeNum)]=LRpred_obs_r2
		LR_alphas[split,edgeRange.index(edgeNum)]=LRalpha
		AR_preds[split,edgeRange.index(edgeNum)]=ARpred_obs_r2
		AR_alphas[split,edgeRange.index(edgeNum)]=ARalpha

	SRmean_preds=np.average(SR_preds[:,edgeRange.index(edgeNum)])
	SRmean_alphas=np.average(SR_alphas[:,edgeRange.index(edgeNum)])
	LRmean_preds=np.average(LR_preds[:,edgeRange.index(edgeNum)])
	LRmean_alphas=np.average(LR_alphas[:,edgeRange.index(edgeNum)])
	ARmean_preds=np.average(AR_preds[:,edgeRange.index(edgeNum)])
	ARmean_alphas=np.average(AR_alphas[:,edgeRange.index(edgeNum)])	
	print('Short-range out-of-samp. pred. w/ ' + str(edgeNum) + ' edges: ' + str(SRmean_preds) + ', alpha='+ str(SRmean_alphas))
	print('Long-range out-of-samp. pred. w/ ' + str(edgeNum) + ' edges: ' + str(LRmean_preds) + ', alpha='+ str(LRmean_alphas))
	print('All-range out-of-samp. pred. w/ ' + str(edgeNum) + ' edges: ' + str(ARmean_preds) + ', alpha='+ str(ARmean_alphas))

print("done")

	
	
		
			

			

	







