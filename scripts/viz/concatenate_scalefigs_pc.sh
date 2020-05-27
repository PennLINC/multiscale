#!/bin/bash
#A="/cbica/projects/pinesParcels/multiscale/scripts/viz/concatenate_scalefigs.sh"
s=$1
A=""	
for i in /cbica/projects/pinesParcels/results/viz/${s}PC_Kequal_*.png; do
	A+=" ${i}"
	done
echo "$A "
exec montage $A  -geometry +3+10 /cbica/projects/pinesParcels/results/viz/${s}pc_over_scales.png
