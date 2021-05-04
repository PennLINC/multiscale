#!/bin/bash

# gifti surface versions of fsaverage5 to use wb geodesic distance calc

mris_convert /cbica/software/external/freesurfer/centos7/6.0.0/subjects/fsaverage5/surf/lh.pial /cbica/projects/pinesParcels/data/lh.pial.surf.gii

mris_convert /cbica/software/external/freesurfer/centos7/6.0.0/subjects/fsaverage5/surf/rh.pial /cbica/projects/pinesParcels/data/rh.pial.surf.gii

/cbica/software/external/connectome_workbench/1.4.2/bin/wb_command -surface-geodesic-distance-all-to-all /cbica/projects/pinesParcels/data/lh.pial.surf.gii /cbica/projects/pinesParcels/data/lh_GeoDist.dconn.nii

/cbica/software/external/connectome_workbench/1.4.2/bin/wb_command -surface-geodesic-distance-all-to-all /cbica/projects/pinesParcels/data/rh.pial.surf.gii /cbica/projects/pinesParcels/data/rh_GeoDist.dconn.nii
