#!/bin/bash
A="/cbica/projects/pinesParcels/multiscale/scripts/viz/concatenate_scalefigs.sh"
# just the first 25 scales for neat 5x5 figs
B=$(ls /cbica/projects/pinesParcels/results/viz/Ind_avg_bw_* | sort -V | head -25 )
for i in $B; do
	A+=" ${i}"
done
echo "$A "
exec montage $A  -geometry +3+10 /cbica/projects/pinesParcels/results/viz/Group_part_MeanBw_over_scales.png

