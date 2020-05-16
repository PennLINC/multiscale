#!/bin/bash
outfile=$1
i2=$2
i3=$3
i4=$4
i5=$5
i6=$6
i7=$7
i8=$8
i9=$9
i10=$10
i11=$11
i12=$12
i13=$13
i14=$14
i15=$15
i16=$16
i17=$17
i18=$18
i19=$19
i20=$20
i21=$21
i22=$22
i23=$23
i24=$24
i25=$25
i26=$26
i27=$27
i28=$28
i29=$29
i30=$30
echo "enter singleplot x-size"
read x
echo "enter singleplot y-size"
read y
xsize=$(( ${x} * 10 ))
ysize=$(( ${y} * 3 ))
dims="${xsize}x${ysize}"
echo "$dims"

 convert -size $dims xc:Khaki composite.gif
 composite -geometry +0+0 $i2 composite.gif composite.gif
 composite -geometry +$xsize+0 $3 composite.gif composite.gif
 composite -geometry +$(( 2 * ${xsize} ))+0 $i4 composite.gif composite.gif
 composite -geometry +$(( 3 * ${xsize} ))+0 $i5 composite.gif composite.gif
 composite -geometry +$(( 4 * ${xsize} ))+0 $i6 composite.gif composite.gif
 composite -geometry +$(( 5 * ${xsize} ))+0 $i7 composite.gif composite.gif
 composite -geometry +$(( 6 * ${xsize} ))+0 $i8 composite.gif composite.gif
 composite -geometry +$(( 7 * ${xsize} ))+0 $i9 composite.gif composite.gif
 composite -geometry +$(( 8 * ${xsize} ))+0 $i10 composite.gif composite.gif
 composite -geometry +$(( 9 * ${xsize} ))+0 $i11 composite.gif composite.gif
 composite -geometry +0+$(( 1 * ${ysize} ))+$(( 1 * ${ysize} )) $i12 composite.gif composite.gif
 composite -geometry +${xsize}+$(( 1 * ${ysize} )) $i13 composite.gif composite.gif
 composite -geometry +$(( 2 * ${xsize} ))+$(( 1 * ${ysize} )) $i14 composite.gif composite.gif
 composite -geometry +$(( 3 * ${xsize} ))+$(( 1 * ${ysize} )) $i15 composite.gif composite.gif
 composite -geometry +$(( 4 * ${xsize} ))+$(( 1 * ${ysize} )) $i16 composite.gif composite.gif
 composite -geometry +$(( 5 * ${xsize} ))+$(( 1 * ${ysize} )) $i17 composite.gif composite.gif
 composite -geometry +$(( 6 * ${xsize} ))+$(( 1 * ${ysize} )) $i18 composite.gif composite.gif
 composite -geometry +$(( 7 * ${xsize} ))+$(( 1 * ${ysize} )) $i19 composite.gif composite.gif
 composite -geometry +$(( 8 * ${xsize} ))+$(( 1 * ${ysize} )) $i20 composite.gif composite.gif
 composite -geometry +$(( 9 * ${xsize} ))+$(( 1 * ${ysize} )) $i21 composite.gif composite.gif
 composite -geometry +0+$(( 2 * ${ysize} ))+$(( 2 * ${ysize} )) $i22 composite.gif composite.gif
 composite -geometry +${xsize}+(( 2 * ${ysize} )) $13 composite.gif composite.gif
 composite -geometry +$(( 2 * ${xsize} ))+$(( 2 * ${ysize} )) $i23 composite.gif composite.gif
 composite -geometry +$(( 3 * ${xsize} ))+$(( 2 * ${ysize} )) $i24 composite.gif composite.gif
 composite -geometry +$(( 4 * ${xsize} ))+$(( 2 * ${ysize} )) $i25 composite.gif composite.gif
 composite -geometry +$(( 5 * ${xsize} ))+$(( 2 * ${ysize} )) $i26 composite.gif composite.gif
 composite -geometry +$(( 6 * ${xsize} ))+$(( 2 * ${ysize} )) $i27 composite.gif composite.gif
 composite -geometry +$(( 7 * ${xsize} ))+$(( 2 * ${ysize} )) $i28 composite.gif composite.gif
 composite -geometry +$(( 8 * ${xsize} ))+$(( 2 * ${ysize} )) $i29 composite.gif composite.gif
 composite -geometry +$(( 9 * ${xsize} ))+$(( 2 * ${ysize} )) $i30 composite.gif composite.gifi
