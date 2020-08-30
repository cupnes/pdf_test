#!/bin/sh

set -uex
# set -ue

X0=12
X1=61.33
X2=110.66
X3=209.34
X4=258.67
X5=308
Y0=12
Y1=45.55
Y2=79.1
Y3=146.2
Y4=179.75
Y5=213

draw_wall() {
	local cl=$1
	local cf=$2
	local cr=$3
	local nl=$4
	local nf=$5
	local nr=$6
	local ll=$7
	local lr=$8
	local rl=$9
	local rr=$10

	if [ $cf -eq 1 ]; then
		echo "$X1 $Y1 m $X1 $Y4 l $X4 $Y4 l $X4 $Y1 l $X1 $Y1 l"
	else
		if [ $nf -eq 1 ]; then
			echo "$X2 $Y2 m $X2 $Y3 l $X3 $Y3 l $X3 $Y2 l $X2 $Y2 l"
		fi
		if [ $nl -eq 1 ]; then
			echo "$X1 $Y1 m $X1 $Y4 l $X2 $Y3 l $X2 $Y2 l $X1 $Y1 l"
		elif [ $lr -eq 1 ]; then
			echo "$X1 $Y2 m $X2 $Y2 l $X2 $Y3 l $X1 $Y3 l"
		fi
		if [ $nr -eq 1 ]; then
			echo "$X3 $Y2 m $X3 $Y3 l $X4 $Y4 l $X4 $Y1 l $X3 $Y2 l"
		elif [ $rl -eq 1 ]; then
			echo "$X4 $Y2 m $X3 $Y2 l $X3 $Y3 l $X4 $Y3 l"
		fi
	fi

	if [ $cl -eq 1 ]; then
		echo "$X0 $Y0 m $X1 $Y1 l $X1 $Y4 l $X0 $Y5 l"
	else
		if [ $ll -eq 1 ]; then
			echo "$X0 $Y1 m $X1 $Y1 l $X1 $Y4 l $X0 $Y4 l"
		elif [ $lr -eq 1 ]; then
			echo "$X0 $Y2 m $X1 $Y2 l $X0 $Y3 m $X1 $Y3 l"
		fi
	fi

	if [ $cr -eq 1 ]; then
		echo "$X5 $Y0 m $X4 $Y1 l $X4 $Y4 l $X5 $Y5 l"
	else
		if [ $rr -eq 1 ]; then
			echo "$X5 $Y1 m $X4 $Y1 l $X4 $Y4 l $X5 $Y4 l"
		elif [ $rl -eq 1 ]; then
			echo "$X4 $Y2 m $X5 $Y2 l $X4 $Y3 m $X5 $Y3 l"
		fi
	fi
}

width=0
height=0
map=''

load_map() {
	local f=$1
	width=$(head -n 1 $f | cut -d' ' -f1)
	height=$(head -n 1 $f | cut -d' ' -f2)
	map=$(tail -n +2 $f)
}

load_map $1
echo "width=$width, height=$height"
for row in $map; do
	echo "row=$row"
done
