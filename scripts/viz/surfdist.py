
import nibabel as nib
import numpy as np
import matplotlib.pyplot as plt
import os
import surfdist as sd
from surfdist import viz, load, utils, analysis

# calculate and display distance from central sulcus at each node:
cmap = 'coolwarm'
base_dir = '/cbica/software/external/freesurfer/centos7/7.2.0/subjects/'
surf = nib.freesurfer.read_geometry(os.path.join(base_dir, 'bert/surf/lh.pial'))
cort = np.sort(nib.freesurfer.read_label(os.path.join(base_dir, 'bert/label/lh.cortex.label')))
sulc = nib.freesurfer.read_morph_data(os.path.join(base_dir, 'bert/surf/lh.sulc'))

# load central sulcus nodes
src  = sd.load.load_freesurfer_label(os.path.join(base_dir, 'bert/label/lh.aparc.a2009s.annot'), 'S_central', cort)

