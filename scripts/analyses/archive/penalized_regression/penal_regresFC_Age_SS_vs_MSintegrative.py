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
import random

### items that apply across all loop iterations
# set alphas for gcv
alphas = np.exp2(np.arange(16) - 10)
splitnum=100
scalepreds=np.zeros(29)
MSpreds=0
for split in range(0,splitnum):
	print('Run ' + str(split))
	# set subject indices for recording train test splits
	indices = list(range(693))
	# copy of this for GCV, copy bc using del operates on the provided Var
	indicesGCV = list(range(693))
	# split into 3rds
	MS_test_indices = random.sample(indices,231)
	MS_predicted_Age=np.zeros(231)
	# remove MS_test from original indices to select sep. SS_test indices
	for index in sorted(MS_test_indices, reverse=True):
		del indices[index]

	# create SS test for evaluating prediction weightings
	SS_test_indices = random.sample(indices,231)
	# combine MS_test and SS test to remove from original indices, remaining to be used for GCV
	test_indices = MS_test_indices + SS_test_indices
	for index in sorted(test_indices, reverse=True):
        	del indicesGCV[index]

	# sort test indices for clean indexing
	MS_test_indices=sorted(MS_test_indices)
	SS_test_indices=sorted(SS_test_indices)
	# for each scale, generate within-scale varofint alpha, accuracy, and untested MS prediction on left out 1/3rd
	for scale in range(2,31):
		# Subject b.w. features	
		filename='/cbica/projects/pinesParcels/results/EffectVecs/scale' + str(scale) + 'for_bw_RRfc.csv'
		data=np.loadtxt(filename,delimiter=',')
		# get x (edges) and y (varofint, age) for all 3rds
		# Divide to predict var of int columns
		GCV_Featvecs=data[indicesGCV,2:(len(data))]
		SSTest_Featvecs=data[SS_test_indices,2:(len(data))]
		MSTest_Featvecs=data[MS_test_indices,2:(len(data))]
		# extract Age variable from first column
		GCV_varofint=data[indicesGCV,0]
		SSTest_varofint=data[SS_test_indices,0]
		MSTest_varofint=data[MS_test_indices,0]	
		# fit model with gcv
		lm = sklearn.linear_model.RidgeCV(alphas=alphas,store_cv_values=True).fit(GCV_Featvecs,GCV_varofint)
		# set prediction alpha to best performing alpha in training set
		alpha=lm.alpha_
		# test prediction on 1st left out sample
		pred_obs_r2 = sklearn.linear_model.Ridge(alpha=alpha).fit(GCV_Featvecs,GCV_varofint).score(SSTest_Featvecs,SSTest_varofint)
		#print('Scale ' + str(scale) + ' prediction: ' + str(pred_obs_r2))
		scalepreds[scale-2]=np.add(scalepreds[scale-2],pred_obs_r2)
		# predict varofint values for 2nd left out sample, weight by prediction accuracy (r2)
		predictedVarOfInt=lm.predict(MSTest_Featvecs)
		# if pseudo r^2 is above 0, weight by prediction accuracy
		if pred_obs_r2 > 0:
			WeightedPrediction=np.multiply(predictedVarOfInt,pred_obs_r2)
			# combine with other scales
			MS_predicted=np.add(MS_predicted_Age,WeightedPrediction)

	MSpredObs_cor=np.corrcoef(MS_predicted,MSTest_varofint)[0,1]
	MSr2=MSpredObs_cor**2
	MSpreds=np.add(MSpreds,MSr2)

mean_SSpreds=np.divide(scalepreds,splitnum)
mean_MSpreds=np.divide(MSpreds,splitnum)
for scale in range(2,31):
	print('Out-of-sample prediction: Scale' + str(scale) + ' r^2 = ' + str(mean_SSpreds[scale-2]))

print('Out-of-sample multiscale prediction: r^2 = '  + str(mean_MSpreds))
