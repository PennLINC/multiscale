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
# set subject indices for recoring train test splits
indices = range(693)
all_preds=np.empty([100,30])
all_alphas=np.empty([100,30])
# for all scales, and using full feature matrix as "scale 31" for convenience
for scale in range(2,32):
	# Subject b.w. features	
	filename='/cbica/projects/pinesParcels/results/EffectVecs/scale' + str(scale) + 'for_bw_RRfc.csv'
	data=np.loadtxt(filename,delimiter=',')
	# Divide to predict var of int columns
	Featvecs=data[:,2:(len(data))]
	# extract EF variable from last column (-1 because python)
	varofint=data[:,0]
	for split in range(0,100):
		# for a few different train and test splits
		# Train and test split from data frame
		xtrain,xtest,ytrain,ytest,indices_train,indices_test=train_test_split(Featvecs,varofint,indices,test_size=0.33,random_state=(split))
		# fit model with gcv
		lm = sklearn.linear_model.RidgeCV(alphas=alphas, store_cv_values=True).fit(xtrain,ytrain)
		# set prediction alpha to best performing alpha in training set
		alpha=lm.alpha_
		# test prediction on left out sample
		pred_obs_r2 = sklearn.linear_model.Ridge(alpha=alpha).fit(xtrain,ytrain).score(xtest,ytest)
		# stack the predictions vertically to be averaged across samples splits
		all_preds[split,scale-2]=pred_obs_r2
		all_alphas[split,scale-2]=alpha

	mean_preds=np.average(all_preds[:,scale-2])
	mean_alphas=np.average(all_alphas[:,scale-2])
	print('Unpermuted out-of-sample prediction: Scale' + str(scale) + ' r^2 = ' + str(mean_preds))
	print('GCV-selected regularization: Scale' + str(scale) + ' alpha = ' + str(mean_alphas))

print("done")

	
	
		
			

			

	







