## imports ##
import scipy
import scipy.io as sio
from os.path import dirname, join as pjoin

import matplotlib.pyplot as plt
import numpy as np 
import pandas as pd
import matplotlib
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.linear_model import RidgeCV
from sklearn.linear_model import Ridge
from sklearn.metrics import mean_squared_error
from sklearn.metrics import r2_score
from sklearn.datasets import RidgeCV

# two big (but 2D!) matrices - one to store variable predictions across scales using louvain comms, other using rotated louvain comms

# CHANGE TO NUMBER OF SCALES ##
master_louv_preds=np.empty([151,6])
master_rot_preds=np.empty([151,6])

# bring in the variables we care about

# CHANGE TO AGE
df=np.loadtxt('/cbica/home/pinesa/prediction_vars_penal_regr_nohead.csv',delimiter=',')

## FOR 2:30

# for each louvain partition
for p in range(1,30):
	filename="part_{0}.mat".format(p)
	# put filename as first column in master dataframe
	master_louv_preds[p,0]=p
	master_rot_preds[p,0]=p
	# get bigass matrix in here... and its data

	# BIGASS MATRIX NEEDS TO BE STACKED TOPOGRAPHY VECTORS

	data_dir = pjoin('/cbica/home/pinesa')
	mat_fname = pjoin(data_dir, filename)
	mat_contents = sio.loadmat(mat_fname)
	data=mat_contents['data']
	ds=data.shape

	# NO ROTATIONS FOR NOW

	# make it 3d so each parcel rotation has the same corresponding info
	df3drep=np.tile(df,(11,1,1))
	# 693 subjs, 11 parcel configs (per louvain community solution), 6 variables of interest (scanid, age, EF, Mood, psychosis, envSES)
	shapely_df=np.swapaxes(df3drep,0,1)
	# slap em on to the end of the feature vectors
	masterdf=np.dstack((shapely_df,data))
	
	# REMOVE THIS BOGGIS AND DISTILL TO AGE
	# col 1 is scan id, 2 is age, 3 is ef, 4 is mood, 5 is psychosis, 6 is ses env, 7 is scan id again. rest are fc vec.
	## Divide var of int and FC vectors ##
	# calc number of fc vec features in the dataframe (+1 because scanid is still there from the part_x mat)
	varofintnum=shapely_df.shape[2]+1
	# originally thought that i needed -1 because python counts from 0, but [0, 0, 6:10] seems to grab the last 4 elements in a 693,11,10 df even though [0,0,10] is out of bounds
	endofdf=masterdf.shape[2]
	# Divide to predict var of int columns
	fcvecs=masterdf[:,:,varofintnum:endofdf]
	# just manually typing in 1:6 in this iteration of the code (excludes subj id)
	varofint=masterdf[:,:,1:6]
	# set alphas for gcv
	
	# CHANGE FOR CONSISTENT PARAMS ACROSS GCVS

	alphas = [1e-3, 1e-2, 1e-1, 1, 1e1, 1e2, 1e3]
	# outcome predictions will be in these 2d arrays (finally back to 2d!)
	# needs to be 3 x 5, 3 rows for each split 5 cols for each var of interest
	all_louv_preds=np.empty([3,5])
	all_rot_preds=np.empty([3,5])
	# mean for when i average em across splits
	mean_louv_preds=[]
	mean_rot_preds=[]
	# for a few different train and test splits

	## CAN CHANGE THIS TO 30 WITH 29 SCAlES INSTEAD OF 151
	for s in range(0,3):
		# Train and test split from data frame
		xtrain,xtest,ytrain,ytest=train_test_split(fcvecs,varofint,test_size=0.33,random_state=(s))
		# for each variable of interest
		# outcome vector of each variable for this split, different vec for rotated and real louvain
		r2_vec_split_louv=[]
		r2_vec_split_rot=[]
		for v in range(0,5):
			# outcome vector of each rotation for this split for this variable
			r2_vec_split_var=[]
			# for each rotation of the parcellation
			for r in range(0,11):
				# extract fc vector from this parcel rotation
				curFCvec=xtrain[:,r,:]
				predcurFCvec=xtest[:,r,:]
				# extract variable of interest from this iteration (each rotation should have the same var of int)
				curVarofInt=ytrain[:,r,v]
				predcurVarofInt=ytest[:,r,v]
				# fit model with gcv
				lm = sklearn.linear_model.RidgeCV(alphas=alphas, store_cv_values=True).fit(curFCvec,curVarofInt)
				# set prediction alpha to best performing alpha in training set
				alpha=lm.alpha_
				# test prediction on left out sample
				pred_obs_r2 = sklearn.linear_model.Ridge(alpha=alpha).fit(curFCvec,curVarofInt).score(predcurFCvec,predcurVarofInt)
				r2_vec_split_var.append(pred_obs_r2)
			# 1st prediction is from unrotated louvain
			r2_vec_split_var_real=r2_vec_split_var[0]
			# 2-11 are rotated louvains, work with means
			r2_vec_split_var_rotated=np.average(r2_vec_split_var[1:11])
			# add em to the r^2 vectors
			r2_vec_split_louv.append(r2_vec_split_var_real)
			r2_vec_split_rot.append(r2_vec_split_var_rotated)
		# stack the 5 predictions vertically to be averaged across samples splits
		all_rot_preds[s,:]=r2_vec_split_rot
		all_louv_preds[s,:]=r2_vec_split_louv
	# mean age predictions
	mean_louv_preds.append(np.average(all_louv_preds[:,0]))
	mean_rot_preds.append(np.average(all_rot_preds[:,0]))
	# mean EF predictions
	mean_louv_preds.append(np.average(all_louv_preds[:,1]))
	mean_rot_preds.append(np.average(all_rot_preds[:,1]))
	# mean Mood predictions
	mean_louv_preds.append(np.average(all_louv_preds[:,2]))
	mean_rot_preds.append(np.average(all_rot_preds[:,2]))
	# mean psychosis predictions
	mean_louv_preds.append(np.average(all_louv_preds[:,3]))
	mean_rot_preds.append(np.average(all_rot_preds[:,3]))
	# mean envSES predictions
	mean_louv_preds.append(np.average(all_louv_preds[:,4]))
	mean_rot_preds.append(np.average(all_rot_preds[:,4]))
	# throw em in (p-1 because there's no part_0.mat)
	master_louv_preds[p-1,1:6]=mean_louv_preds
	master_rot_preds[p-1,1:6]=mean_rot_preds

np.savetxt('master_louv_preds_ridge',master_louv_preds)
np.savetxt('master_rot_preds_ridge',master_rot_preds)

	
	
		
			

			

	







