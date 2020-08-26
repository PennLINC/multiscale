#!/bin/bash

# 8/25 - CHANGED to just run on group or individualized-partition fc values

A="/cbica/projects/pinesParcels/multiscale/scripts/viz/concatenate_scalefigs.sh"
for i in /cbica/projects/pinesParcels/results/viz/Group_Effect_at*_EF_g*; do
	A+=" ${i}"
done
echo "$A "
exec montage $A  -geometry +3+10 /cbica/projects/pinesParcels/results/viz/Group_part_EFSegregEffect_over_scales_g.png
