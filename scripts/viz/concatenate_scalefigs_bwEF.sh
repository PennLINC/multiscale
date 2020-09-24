#!/bin/bash

# 8/25 - CHANGED to just run on group or individualized-partition fc values

A="/cbica/projects/pinesParcels/multiscale/scripts/viz/concatenate_scalefigs.sh"
A=""
B=$(ls /cbica/projects/pinesParcels/results/viz/BwEF_K* | sort -V | head -25 )
for i in $B; do
	A+=" ${i}"
done
echo "$A "
exec montage $A  -geometry +3+10 /cbica/projects/pinesParcels/results/viz/EFbwEffect_over_scales.png
