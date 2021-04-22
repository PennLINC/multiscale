import numpy as np
import os.path
from os import path
# load in subject names
s_file = open("/cbica/projects/pinesParcels/data/bblids.txt")
sfile_contents = s_file. read()
scontents_split = sfile_contents. splitlines()
# initialize arrays
lambda1_array=np.empty((len(scontents_split),2))
PG1_vertexvals=np.empty((len(scontents_split),17735))
for s in range(0,len(scontents_split)):
	# get this specific subject
	sid=scontents_split[s]
	# load in dmapping results
	savepathr= "/cbica/projects/pinesParcels/data/CombinedData/" + str(sid) + "/vertexwise_res.npy"
	if path.exists(savepathr):
		res=np.load(savepathr,allow_pickle=True)
		lambdas=res.item()['lambdas']
		# write lambda one and subject ID to array
		lambda1_array[s,0]=sid
		lambda1_array[s,1]=lambdas[0]
		# load in dmapping vertex values
		savepathe= "/cbica/projects/pinesParcels/data/CombinedData/" + str(sid) + "/vertexwise_emb.npy"
		emb=np.load(savepathe)	
		# write vertex values and subject ID to array
		PG1_vertexvals[s,1:17735]=emb[:,0]
		PG1_vertexvals[s,0]=sid
	else:
		print("missing file(s)")
		print(sid)

