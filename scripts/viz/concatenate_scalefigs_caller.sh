#!/bin/bash
A="/cbica/projects/pinesParcels/multiscale/scripts/viz/concatenate_scalefigs.sh"
for i in /cbica/projects/pinesParcels/results/viz/Gro_Con_kK_*; do
	A+=" ${i}"
done
echo "$A "
exec $A
