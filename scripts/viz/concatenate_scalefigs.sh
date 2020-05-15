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
xsize=(expr x*10)
ysize=(expr y*3)

 convert -size $xsize x $ysize xc:Khaki composite.gif
  composite -geometry +0+0 $2 composite.gif composite.gif
  composite -geometry +$xsize+0 $3 composite.gif composite.gif
  composite -geometry +(expr(2*$xsize))+0 $4 composite.gif composite.gif
  composite -geometry +(expr(3*$xsize))+0 $5 composite.gif composite.gif
  composite -geometry +(expr(4*$xsize))+0 $6 composite.gif composite.gif
  composite -geometry +(expr(5*$xsize))+0 $7 composite.gif composite.gif
  composite -geometry +(expr(6*$xsize))+0 $8 composite.gif composite.gif
  composite -geometry +(expr(7*$xsize))+0 $9 composite.gif composite.gif
  composite -geometry +(expr(8*$xsize))+0 $10 composite.gif composite.gif   
  composite -geometry +(expr(9*$xsize))+0 $11 composite.gif composite.gif
  composite -geometry +0+(expr(1*$ysize))+(expr(1*$ysize)) $12 composite.gif composite.gif
  composite -geometry +$xsize+(expr(1*$ysize)) $13 composite.gif composite.gif
  composite -geometry +(expr(2*$xsize))+(expr(1*$ysize)) $14 composite.gif composite.gif
  composite -geometry +(expr(3*$xsize))+(expr(1*$ysize)) $15 composite.gif composite.gif
  composite -geometry +(expr(4*$xsize))+(expr(1*$ysize)) $16 composite.gif composite.gif
  composite -geometry +(expr(5*$xsize))+(expr(1*$ysize)) $17 composite.gif composite.gif
  composite -geometry +(expr(6*$xsize))+(expr(1*$ysize)) $18 composite.gif composite.gif
  composite -geometry +(expr(7*$xsize))+(expr(1*$ysize)) $19 composite.gif composite.gif
  composite -geometry +(expr(8*$xsize))+(expr(1*$ysize)) $20 composite.gif composite.gif    
  composite -geometry +(expr(9*$xsize))+(expr(1*$ysize)) $21 composite.gif composite.gif
  composite -geometry +0+(expr(2*$ysize))+(expr(2*$ysize)) $22 composite.gif composite.gif
  composite -geometry +$xsize+(expr(2*$ysize)) $13 composite.gif composite.gif
  composite -geometry +(expr(2*$xsize))+(expr(2*$ysize)) $23 composite.gif composite.gif
  composite -geometry +(expr(3*$xsize))+(expr(2*$ysize)) $24 composite.gif composite.gif
  composite -geometry +(expr(4*$xsize))+(expr(2*$ysize)) $25 composite.gif composite.gif
  composite -geometry +(expr(5*$xsize))+(expr(2*$ysize)) $26 composite.gif composite.gif
  composite -geometry +(expr(6*$xsize))+(expr(2*$ysize)) $27 composite.gif composite.gif
  composite -geometry +(expr(7*$xsize))+(expr(2*$ysize)) $28 composite.gif composite.gif
  composite -geometry +(expr(8*$xsize))+(expr(2*$ysize)) $29 composite.gif composite.gif
  composite -geometry +(expr(9*$xsize))+(expr(2*$ysize)) $30 composite.gif composite.gif

