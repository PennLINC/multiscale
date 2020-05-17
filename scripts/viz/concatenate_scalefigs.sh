#!/bin/bash
A="/cbica/projects/pinesParcels/multiscale/scripts/viz/concatenate_scalefigs.sh"
for i in /cbica/projects/pinesParcels/results/viz/Gro_Con_Kequal_*; do
	A+=" ${i}"
done
echo "$A "
exec montage $A  -geometry +3+10 /cbica/projects/pinesParcels/results/viz/Group_partitions_over_scales.png
