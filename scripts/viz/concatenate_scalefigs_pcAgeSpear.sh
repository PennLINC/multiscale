#!/bin/bash
#A="/cbica/projects/pinesParcels/multiscale/scripts/viz/concatenate_scalefigs.sh"
A=""	
for i in /cbica/projects/pinesParcels/results/viz/PosPCAge_scale*.png; do
	A+=" ${i}"
	done
echo "$A "
exec montage $A  -geometry +3+10 /cbica/projects/pinesParcels/results/viz/PospcAge_over_scales.png
