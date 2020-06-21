#!/bin/bash
# nsubjs = 693, but python likes 0s as 1s
for i in {0..1}
#for i in {0..692}
do
echo ${i}
qsub -l h_vmem=40G bash2py.sh ${i}
done
