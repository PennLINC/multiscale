#!/bin/bash
# nsubjs = 693, but python likes 0s as 1s
for i in {0..1}
#for i in {0..692}
do
echo ${i}
qsub -S python -l h_vmem=12G,s_vmem=11G /cbica/projects/pinesParcels/multiscale/scripts/derive_percygrads/fcmat_to_threshCosSim.py ${i}

done
