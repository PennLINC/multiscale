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
import pygam
from pygam import LinearGAM, s, l
### EF b/w feature ridge prediction and permutation comparisons - age controlled for prior to this script
### AI indicates "Age-independent", as EF scores are age (and motion) - controlled
# for prinout, we will want to store out-of-sample prediction, and alpha selected, so 2 columns
summary_preds=np.empty([4,2])
# need a different, subject-level prediction DF so we can unpack predicted EF in R
# first column is additive predicted EF, second column is number of times it was added, third is estimated EF controlling for age and motion
subject_preds_AI=np.zeros([693,3])
# equiv. for permutation predictions
permut_subject_preds_AI=np.zeros([693,3])
# Subject b.w. features	
filename='/cbica/projects/pinesParcels/results/EffectVecs/AgeMotEFMem'
data_AI=np.loadtxt(filename,delimiter=',')
# Divide to predict variable of interest from feature columns
Featvecs_AI=data_AI[:,:-3]
# extract EF variable from last column
varofintAI=data_AI[:,-1]
# extract motion from second to last column
mot=data_AI[:,-2]
# extract age from third to last column
age=data_AI[:,-3]
# set alphas testable for gcv
alphas = np.exp2(np.arange(16)-10)
# set subject indices for recoring train test splits
indices = range(693)
# permutation initialization: 1000 iterations of across-subject permutations
permutedEF=np.zeros([693,1000])
# 1000 permutations
permutIndices=[np.random.permutation(indices) for i in range(1000)]
for i in range(1000):
	permutedEF[:,i]=varofintAI[permutIndices[i]]

# outcome predictions will be in these arrays
all_preds=np.empty([100,1])
all_permut_preds=np.empty([1000,1])
# outcome regularization weightings will be in these arrays
all_preds_alphas=np.empty([100,1])
all_permut_preds_alphas=np.empty([1000,1])
# feature weights from the real model will be stored in this array
featureWeights_AI=np.empty([100,data_AI.shape[1]-3])
# adding MSE quantification
mse_AI=np.empty([100,1])
# run real predictions 100 times. Allows for each subject to be randomly allocated to the testing third multiple times.
for split in range(0,100):
# for a few different train and test splits
	# Train and test split from data frame
	xtrain_AI,xtest_AI,ytrain_AI,ytest_AI,indices_train_AI,indices_test_AI=train_test_split(Featvecs_AI,varofintAI,indices,test_size=0.33,random_state=(split))
	# make dataframe of non-brain variables to regress covariates from EF in training
	df=np.array([age[indices_train_AI],mot[indices_train_AI],varofintAI[indices_train_AI]])
	# transpose so subjects are rows
	dft=np.transpose(df)
	# regress covariates from EF in training sample (Linear GAM still has spline term)
	GAMFit=LinearGAM(s(0,n_splines=5) + l(1)).fit(dft,dft[:,2])
	# get residuals
	residsvec=GAMFit.deviance_residuals(dft[:,[0,1,2]],dft[:,2])
	# set ytrain to residuals
	ytrain_AI=residsvec
	# make equivalent dataframe for testing sample, but fit age and motion effects from training model
	df2=np.array([age[indices_test_AI],mot[indices_test_AI],varofintAI[indices_test_AI]])
	df2t=np.transpose(df2)
	# apply model to unseen data to get those residuals for testing set
	testResidsvec=GAMFit.deviance_residuals(df2t[:,[0,1,2]],df2t[:,2])
	# replace y test with age/motion controlled EF
	ytest_AI=testResidsvec
	# fit model with gcv
	lm_AI = sklearn.linear_model.RidgeCV(alphas=alphas, store_cv_values=True).fit(xtrain_AI,ytrain_AI)
	# set prediction alpha to best performing alpha in training set
	alpha_AI=lm_AI.alpha_
	# save regularization weightings for this split
	all_preds_alphas[split,0]=alpha_AI
	# store vector of feature weights for visualizations
	featureWeights_AI[split,:]=lm_AI.coef_
	# get predicted EF values
	predEF_AI=lm_AI.predict(xtest_AI)
	# add predicted EF to subjects (indices) this iteration was not trained on, add another counter to adjacent column
	subject_preds_AI[indices_test_AI,0]=subject_preds_AI[indices_test_AI,0]+predEF_AI
	subject_preds_AI[indices_test_AI,1]=subject_preds_AI[indices_test_AI,1]+1
	subject_preds_AI[indices_test_AI,2]=subject_preds_AI[indices_test_AI,2]+testResidsvec
	# test prediction on left out sample
	predObsCor=np.corrcoef(predEF_AI,ytest_AI)
	# stack the predictions vertically to be averaged across samples splits
	all_preds[split,0]=predObsCor[0,1]
	# save mean squared error
	mse_AI[split,0]=sklearn.metrics.mean_squared_error(ytest_AI,predEF_AI)
	
# for permuted predictions
for permut in range(0,1000):
        # extract this shuffled ef-subject correspondence
	varofint_permut=permutedEF[:,permut];
	# Train and test split from data frame
	xtrain_AI,xtest_AI,ytrain_AI,ytest_AI,indices_train_AI,indices_test_AI=train_test_split(Featvecs_AI,varofint_permut,indices,test_size=0.33,random_state=(permut))
	# Train on permuted. Predict on non-permuted, so test-EF scores are real (Extracted from varofint rather than permutedEF)
	ytest_AI=varofintAI[indices_test_AI]
	# make dataframe of non-brain variables to regress covariates from EF in training
	df=np.array([age[indices_train_AI],mot[indices_train_AI],varofint_permut[indices_train_AI]])
	# transpose so subjects are rows
	dft=np.transpose(df)
	# regress covariates from EF in training sample (Linear GAM still has spline term)
	GAMFit=LinearGAM(s(0,n_splines=5) + l(1)).fit(dft,dft[:,2])
	# get residuals
	residsvec=GAMFit.deviance_residuals(dft[:,[0,1,2]],dft[:,2])
	# set y_train to residuals
	ytrain_AI=residsvec
	# make equivalent dataframe for testing sample, but fit age and motion effects from training model
	df2=np.array([age[indices_test_AI],mot[indices_test_AI],varofintAI[indices_test_AI]])
	df2t=np.transpose(df2)
	# apply model to unseen data to get those residuals for testing set
	testResidvec=GAMFit.deviance_residuals(df2t[:,[0,1,2]],df2t[:,2])
	# replace y test with age/motion controlled EF
	ytest_AI=testResidsvec
	# fit model with gcv
	lm_AI = sklearn.linear_model.RidgeCV(alphas=alphas, store_cv_values=True).fit(xtrain_AI,ytrain_AI)
	# set prediction alpha to best performing alpha in training set
	alpha_AI=lm_AI.alpha_
	# save regularization weightings for this split
	all_permut_preds_alphas[permut,0]=alpha_AI
	# get predicted EF values
	predEF_AI=lm_AI.predict(xtest_AI)
	# use correlation to eval. predictions
	permutCor=np.corrcoef(predEF_AI,ytest_AI)
	all_permut_preds[permut,0]=permutCor[0,1]
	# add predicted EF to indices this iteration was not trained on, add counter to adjacent column 
	permut_subject_preds_AI[indices_test_AI,0]=permut_subject_preds_AI[indices_test_AI,0]+predEF_AI
	permut_subject_preds_AI[indices_test_AI,1]=permut_subject_preds_AI[indices_test_AI,1]+1
	permut_subject_preds_AI[indices_test_AI,2]=permut_subject_preds_AI[indices_test_AI,2]+testResidsvec

# mean age predictions
mean_preds_AI=np.average(all_preds[:,0])
mean_permut_preds=np.average(all_permut_preds[:,0])
# mean alphas
mean_alphas_AI=np.average(all_preds_alphas[:,0])
mean_alphas_permut=np.average(all_permut_preds_alphas[:])
# mean feature weights
mean_featureWeights_AI=np.average(featureWeights_AI,axis=0)
# mean EF predictions
# throw em in (p-1 because there's no part_0.mat)
summary_preds[0,0]=mean_preds_AI
summary_preds[0,1]=mean_alphas_AI
print("Unpermuted out-of-sample predicted vs. observed correlation:" + str(mean_preds_AI))
print("Average Optimal Regularization Weighting:" + str(mean_alphas_AI))
allPredsFN='/cbica/projects/pinesParcels/data/aggregated_data/Predicted_Obs_Cors_Mem.csv'
np.savetxt(allPredsFN,all_preds,delimiter=",")
# mean MSE
meanMSE=np.average(mse_AI[:,0])
print("Mean Mean Squared Error (unpermuted):" + str(meanMSE))
featureweightsFN='/cbica/projects/pinesParcels/data/aggregated_data/FeatureWeights_AI_Mem.csv'
np.savetxt(featureweightsFN,mean_featureWeights_AI,delimiter=",")
# save predicted subject info
subjpredsFN='/cbica/projects/pinesParcels/data/aggregated_data/SubjPreds_AI_Mem.csv'
np.savetxt(subjpredsFN,subject_preds_AI,delimiter=",")
# save permuted predictions vector
permpredsFN='/cbica/projects/pinesParcels/data/aggregated_data/PermutPreds_AI_Mem.csv'
np.savetxt(permpredsFN,all_permut_preds,delimiter=",")

