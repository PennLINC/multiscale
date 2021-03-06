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


# two big (but 2D!) matrices - one to store variable predictions across scales using nmf topographies
# we will want to store scale, out-of-sample prediction, and alpha selected for each scale, so 3 columns
summary_topo_preds=np.empty([29,3])
summary_topo_preds_permut=np.empty([29,3])

# need a different, subject-level prediction DF so we can control for motion and sex in R on output
subject_topo_preds=np.empty([29,3])
subject_topo_preds_permut=np.empty([29,3])

# bring in the variables we care about (bblid,age,motion,sex)
df=np.loadtxt('/cbica/projects/pinesParcels/results/EffectVecs/forMLpc.csv',delimiter=',')
df_permut=np.loadtxt('/cbica/projects/pinesParcels/results/EffectVecs/forMLpc_permut.csv',delimiter=',')
# one of several instances where we need to play nicely with matlab: import matlab subject order for reordering to match topogs
subjs=np.loadtxt('/cbica/projects/pinesParcels/data/bblids.txt')

# brief pandas section just for re-ordering
pd_df=pd.DataFrame(df, columns=['bblid', 'Age', 'Motion', 'Sex'])
pd_df_permut=pd.DataFrame(df_permut, columns=['bblid', 'Age', 'Motion', 'Sex'])
pd_subjs=pd.DataFrame(subjs, columns=['bblid'])
pd_merged=pd_df.merge(pd_subjs, on=['bblid'], how='right')
pd_merged_permut=pd_df_permut.merge(pd_subjs, on=['bblid'], how='right')
# take matlab-ordered df back to numpy
merged=pd_merged.to_numpy()
merged_permut=pd_merged_permut.to_numpy()

# for each scale
for K in range(2,31):
	print(K)	
	# Subject Topographies for this scale (17734 x 693 x K)	
	filename='/cbica/projects/pinesParcels/data/aggregated_data/Scale' + str(K) + '_Topographies.mat'

	# put scale as first cell for this row in master dataframes 
	# (K - 1 because we start at scale 2, -1 again because python starts at 0)
	summary_topo_preds[K-2,0]=K
	summary_topo_preds_permut[K-2,0]=K

	# load stacked topography vectors	
	mat_contents = h5py.File(filename,'r')
	# massage matlab's odd file format into an array
	data=mat_contents['BigMat']
	# convert to numpy
	np_data=np.array(data)
	# need to reshape so that topography features are in a Kx17734 vector for each subject
	resh_data=np_data.transpose(1,2,0).reshape(693,-1,order='F')
	# return an error if shape does not indicate Kx17734 as new dimension length in 2d matrix
	if (resh_data.shape[1] == (K*17734)):
		print ("Vectorized topographies seem to be the correct length")
	else:
		print("Vectorized topographies are not of length K * 17734, back to the drawing board bub")
	
	# slap age on to the end of feature vectors for prediction dataframe format
	masterdf=np.hstack((resh_data,merged))
	masterdf_permut=np.hstack((resh_data,merged_permut))	
	## Divide var of int and FC vectors ##
	# get index of age variable after topography vector  (+1 because scanid is still there from the part_x mat)
	varofintnum=resh_data.shape[1]+1
	
	# Divide to predict var of int columns
	topogvecs=masterdf[:,0:resh_data.shape[1]]

	# just manually typing in 1:6 in this iteration of the code (excludes subj id)
	varofint=masterdf[:,varofintnum]
	varofint_permut=masterdf_permut[:,varofintnum]
	# set alphas for gcv
	# use Zaixu's alpha range
	alphas = np.exp2(np.arange(16) - 10)

	# outcome predictions will be in these 2d arrays (finally back to 2d!)
	# needs to be 12 x 1, 12 rows for each split 1 col for each var of interest
	all_preds=np.empty([12,1])
	all_permut_preds=np.empty([12,1])
	all_preds_alphas=np.empty([12,1])
	all_permut_preds_alphas=np.empty([12,1])

	# average feature weights K x number of verts long
	all_featureWeights=np.empty([12,(K*17734)])

	for split in range(0,12):
	# for a few different train and test splits
		# Train and test split from data frame
		xtrain,xtest,ytrain,ytest=train_test_split(topogvecs,varofint,test_size=0.33,random_state=(split))
		# same for permuted data
		xtrain_p,xtest_p,ytrain_p,ytest_p=train_test_split(topogvecs,varofint_permut,test_size=0.33,random_state=(split))
		# outcome vector for this split, different vec for permuted and real data
		r2_vec_split=[]
		r2_vec_split_permut=[]
		# fit model with gcv
		lm = sklearn.linear_model.RidgeCV(alphas=alphas, store_cv_values=True).fit(xtrain,ytrain)
		# same for permuted
		lm_p = sklearn.linear_model.RidgeCV(alphas=alphas, store_cv_values=True).fit(xtrain_p,ytrain_p)
		# set prediction alpha to best performing alpha in training set
		alpha=lm.alpha_
		all_preds_alphas[split,:]=alpha
		alpha_p=lm_p.alpha_
		all_permut_preds_alphas[split,:]=alpha_p
		
		# store vector of feature weights for cortical surface projections
		Verts1toVertsK=lm.coef_
		all_featureWeights[split,:]=Verts1toVertsK
		# test prediction on left out sample
		pred_obs_r2 = sklearn.linear_model.Ridge(alpha=alpha).fit(xtrain,ytrain).score(xtest,ytest)
		# parallel prediction for permuted data ######
		pred_obs_r2_permut = sklearn.linear_model.Ridge(alpha=alpha_p).fit(xtrain_p,ytrain_p).score(xtest_p,ytest_p)
		# stack the 5 predictions vertically to be averaged across samples splits
		all_preds[split,:]=pred_obs_r2
		all_permut_preds[split,:]=pred_obs_r2_permut	
	
	# mean age predictions
	mean_preds=np.average(all_preds[:])
	mean_preds_permut=np.average(all_permut_preds[:])
	# mean alphas
	mean_alphas=np.average(all_preds_alphas[:])
	mean_alphas_permut=np.average(all_permut_preds_alphas[:])
	
	# mean feature weights
	mean_featureWeights=np.average(all_featureWeights,axis=0)

	##mean_permut_preds.append(np.average(all_rot_preds[:,0]))
	# mean EF predictions
	#mean_louv_preds.append(np.average(all_louv_preds[:,1]))
	#mean_rot_preds.append(np.average(all_rot_preds[:,1]))
	# throw em in (p-1 because there's no part_0.mat)
	summary_topo_preds[K-2,1]=mean_preds
	summary_topo_preds[K-2,2]=mean_alphas
	summary_topo_preds_permut[K-2,1]=mean_preds_permut
	summary_topo_preds_permut[K-2,2]=mean_alphas_permut
	#summary_topo_preds_permut[K-2,1]=mean_preds_permut
	print("Unpermuted out-of-sample prediction:" + str(mean_preds))
	print("Permuted prediction" + str(mean_preds_permut))
	print("Average Optimal Regularization Weighting" + str(mean_alphas))
	print("Permuted Average Optimal Regularization Weighting" + str(mean_alphas_permut))	
	featureweightsFN='/cbica/projects/pinesParcels/data/aggregated_data/FeatureWeightsScale_' + str(K) + '.csv'
	np.savetxt(featureweightsFN,mean_featureWeights,delimiter=",")

np.savetxt('topo_preds_ridge',summary_topo_preds)
#np.savetxt('master_rot_preds_ridge',master_rot_preds)

	
	
		
			

			

	







