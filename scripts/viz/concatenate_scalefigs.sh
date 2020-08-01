#!/bin/bash
A="/cbica/projects/pinesParcels/multiscale/scripts/viz/concatenate_scalefigs.sh"
A=""
B=$(ls /cbica/projects/pinesParcels/results/viz/Gro_Con_Kequal_* | sort -V | head -25 )
for i in $B; do
	A+=" ${i}"
done
echo "$A "
exec montage $A  -geometry +3+10 /cbica/projects/pinesParcels/results/viz/ConsOverScakes.png
