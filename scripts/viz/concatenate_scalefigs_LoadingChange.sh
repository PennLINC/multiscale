#!/bin/bash
A="/cbica/projects/pinesParcels/multiscale/scripts/viz/concatenate_scalefigs.sh"
for i in /cbica/projects/pinesParcels/results/viz/LoadingChange_Scale*; do
	A+=" ${i}"
done
echo "$A "
exec montage $A  -geometry +3+10 /cbica/projects/pinesParcels/results/viz/LoadingChange_over_scales.png
