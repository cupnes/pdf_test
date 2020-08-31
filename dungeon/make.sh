#!/bin/bash

set -uex
# set -ue

MAP_FILE=$1
START_OBJ_ID=$2

WORK_DIR=$(mktemp -d)
# trap "rm -rf $WORK_DIR" EXIT

CONTENTS_HEAD_TMPL=contents_head.tmpl
CONTENTS_FOOT_TMPL=contents_foot.tmpl
DRAW_WALL_INDENT='\t'
DIRECTION_LIST='w n e s'

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

PAGES_OBJ_ID=3

current_obj_id=0

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
	local rr=${10}

	echo -e "${DRAW_WALL_INDENT}% DEBUG obj_id=$current_obj_id wall_pat=$cl$cf$cr$nl$nf$nr$ll$lr$rl$rr"

	if [ $cf -eq 1 ]; then
		echo -e "$DRAW_WALL_INDENT$X1 $Y1 m $X1 $Y4 l $X4 $Y4 l $X4 $Y1 l $X1 $Y1 l"
	else
		if [ $nf -eq 1 ]; then
			echo -e "$DRAW_WALL_INDENT$X2 $Y2 m $X2 $Y3 l $X3 $Y3 l $X3 $Y2 l $X2 $Y2 l"
		fi
		if [ $nl -eq 1 ]; then
			echo -e "$DRAW_WALL_INDENT$X1 $Y1 m $X1 $Y4 l $X2 $Y3 l $X2 $Y2 l $X1 $Y1 l"
		elif [ $lr -eq 1 ]; then
			echo -e "$DRAW_WALL_INDENT$X1 $Y2 m $X2 $Y2 l $X2 $Y3 l $X1 $Y3 l"
		fi
		if [ $nr -eq 1 ]; then
			echo -e "$DRAW_WALL_INDENT$X3 $Y2 m $X3 $Y3 l $X4 $Y4 l $X4 $Y1 l $X3 $Y2 l"
		elif [ $rl -eq 1 ]; then
			echo -e "$DRAW_WALL_INDENT$X4 $Y2 m $X3 $Y2 l $X3 $Y3 l $X4 $Y3 l"
		fi
	fi

	if [ $cl -eq 1 ]; then
		echo -e "$DRAW_WALL_INDENT$X0 $Y0 m $X1 $Y1 l $X1 $Y4 l $X0 $Y5 l"
	else
		if [ $ll -eq 1 ]; then
			echo -e "$DRAW_WALL_INDENT$X0 $Y1 m $X1 $Y1 l $X1 $Y4 l $X0 $Y4 l"
		elif [ $lr -eq 1 ]; then
			echo -e "$DRAW_WALL_INDENT$X0 $Y2 m $X1 $Y2 l $X0 $Y3 m $X1 $Y3 l"
		fi
	fi

	if [ $cr -eq 1 ]; then
		echo -e "$DRAW_WALL_INDENT$X5 $Y0 m $X4 $Y1 l $X4 $Y4 l $X5 $Y5 l"
	else
		if [ $rr -eq 1 ]; then
			echo -e "$DRAW_WALL_INDENT$X5 $Y1 m $X4 $Y1 l $X4 $Y4 l $X5 $Y4 l"
		elif [ $rl -eq 1 ]; then
			echo -e "$DRAW_WALL_INDENT$X4 $Y2 m $X5 $Y2 l $X4 $Y3 m $X5 $Y3 l"
		fi
	fi
}

width=0
height=0
load_map_attr() {
	width=$(head -n 1 $MAP_FILE | cut -d' ' -f1)
	height=$(head -n 1 $MAP_FILE | cut -d' ' -f2)
}

get_lfr() {
	local wall_stat=$1
	local wnes=$(echo "obase=2;ibase=16;1$wall_stat" | bc | cut -c2-5)
	local d=$2
	local l
	local f
	local r
	case $d in
	w)
		l=$(echo $wnes | cut -c4)
		f=$(echo $wnes | cut -c1)
		r=$(echo $wnes | cut -c2)
		;;
	n)
		l=$(echo $wnes | cut -c1)
		f=$(echo $wnes | cut -c2)
		r=$(echo $wnes | cut -c3)
		;;
	e)
		l=$(echo $wnes | cut -c2)
		f=$(echo $wnes | cut -c3)
		r=$(echo $wnes | cut -c4)
		;;
	s)
		l=$(echo $wnes | cut -c3)
		f=$(echo $wnes | cut -c4)
		r=$(echo $wnes | cut -c1)
		;;
	esac
	echo "$l$f$r"
}

# 1 <= x <= $width
# 1 <= y <= $height
get_wall_stat() {
	local x=$1
	local y=$2
	echo $(sed -n $((y + 2))p $MAP_FILE | cut -c$((x + 1)))
}

get_next_wall_stat() {
	local x=$1
	local y=$2
	local d=$3

	local wall_stat

	case $d in
	w)
		wall_stat=$(get_wall_stat $((x - 1)) $y)
		;;
	n)
		wall_stat=$(get_wall_stat $x $((y - 1)))
		;;
	e)
		wall_stat=$(get_wall_stat $((x + 1)) $y)
		;;
	s)
		wall_stat=$(get_wall_stat $x $((y + 1)))
		;;
	esac
	echo $wall_stat
}

get_next_left_wall_stat_direction() {
	local x=$1
	local y=$2
	local d=$3

	local wall_stat
	local nd

	case $d in
	w)
		wall_stat=$(get_wall_stat $((x - 1)) $((y + 1)))
		nd=s
		;;
	n)
		wall_stat=$(get_wall_stat $((x - 1)) $((y - 1)))
		nd=w
		;;
	e)
		wall_stat=$(get_wall_stat $((x + 1)) $((y - 1)))
		nd=n
		;;
	s)
		wall_stat=$(get_wall_stat $((x + 1)) $((y + 1)))
		nd=e
		;;
	esac
	echo "$wall_stat$nd"
}

get_next_right_wall_stat_direction() {
	local x=$1
	local y=$2
	local d=$3

	local wall_stat
	local nd

	case $d in
	w)
		wall_stat=$(get_wall_stat $((x - 1)) $((y - 1)))
		nd=n
		;;
	n)
		wall_stat=$(get_wall_stat $((x + 1)) $((y - 1)))
		nd=e
		;;
	e)
		wall_stat=$(get_wall_stat $((x + 1)) $((y + 1)))
		nd=s
		;;
	s)
		wall_stat=$(get_wall_stat $((x - 1)) $((y + 1)))
		nd=w
		;;
	esac
	echo "$wall_stat$nd"
}

# 1 <= x <= $width
# 1 <= y <= $height
# d in 'w' 'n' 'e' 's'
get_wall_pattern() {
	local x=$1
	local y=$2
	local d=$3

	local wall_stat
	local wall_stat_d
	local lfr

	local cl
	local cf
	local cr
	local nl
	local nf
	local nr
	local ll
	local lr
	local rl
	local rr

	wall_stat=$(get_wall_stat $x $y)
	lfr=$(get_lfr $wall_stat $d)
	cl=$(echo $lfr | cut -c1)
	cf=$(echo $lfr | cut -c2)
	cr=$(echo $lfr | cut -c3)

	wall_stat=$(get_next_wall_stat $x $y $d)
	lfr=$(get_lfr $wall_stat $d)
	nl=$(echo $lfr | cut -c1)
	nf=$(echo $lfr | cut -c2)
	nr=$(echo $lfr | cut -c3)

	wall_stat_d=$(get_next_left_wall_stat_direction $x $y $d)
	lfr=$(get_lfr $(echo $wall_stat_d | cut -c1) $(echo $wall_stat_d | cut -c2))
	ll=$(echo $lfr | cut -c1)
	lr=$(echo $lfr | cut -c3)

	wall_stat_d=$(get_next_right_wall_stat_direction $x $y $d)
	lfr=$(get_lfr $(echo $wall_stat_d | cut -c1) $(echo $wall_stat_d | cut -c2))
	rl=$(echo $lfr | cut -c1)
	rr=$(echo $lfr | cut -c3)

	echo "$cl$cf$cr$nl$nf$nr$ll$lr$rl$rr"
}

# 1 <= x <= $width
# 1 <= y <= $height
# d in 'w' 'n' 'e' 's'
draw_wall_xyd() {
	local x=$1
	local y=$2
	local d=$3

	local wall_stat
	local wall_stat_d
	local lfr

	local cl
	local cf
	local cr
	local nl
	local nf
	local nr
	local ll
	local lr
	local rl
	local rr

	wall_stat=$(get_wall_stat $x $y)
	lfr=$(get_lfr $wall_stat $d)
	cl=$(echo $lfr | cut -c1)
	cf=$(echo $lfr | cut -c2)
	cr=$(echo $lfr | cut -c3)

	wall_stat=$(get_next_wall_stat $x $y $d)
	lfr=$(get_lfr $wall_stat $d)
	nl=$(echo $lfr | cut -c1)
	nf=$(echo $lfr | cut -c2)
	nr=$(echo $lfr | cut -c3)

	wall_stat_d=$(get_next_left_wall_stat_direction $x $y $d)
	lfr=$(get_lfr $(echo $wall_stat_d | cut -c1) $(echo $wall_stat_d | cut -c2))
	ll=$(echo $lfr | cut -c1)
	lr=$(echo $lfr | cut -c3)

	wall_stat_d=$(get_next_right_wall_stat_direction $x $y $d)
	lfr=$(get_lfr $(echo $wall_stat_d | cut -c1) $(echo $wall_stat_d | cut -c2))
	rl=$(echo $lfr | cut -c1)
	rr=$(echo $lfr | cut -c3)

	draw_wall $cl $cf $cr $nl $nf $nr $ll $lr $rl $rr
}

make_a_contents_obj() {
	local x=$1
	local y=$2
	local d=$3

	sed "s/OBJ_ID/$current_obj_id/" $CONTENTS_HEAD_TMPL
	draw_wall_xyd $x $y $d
	cat $CONTENTS_FOOT_TMPL
	echo

	current_obj_id=$((current_obj_id + 1))
}

make_contents_obj_all() {
	local x
	local y
	local d
	local wall_pat
	local obj_id
	local wall_pat_line

	local t=$WORK_DIR/contents.obj
	local lst=$WORK_DIR/coord_objid.lst

	touch $t $lst
	for y in $(seq $height); do
		for x in $(seq $width); do
			for d in $DIRECTION_LIST; do
				wall_pat=$(get_wall_pattern $x $y $d)
				wall_pat_line=$(grep "wall_pat=$wall_pat" $t || echo "none")
				if [ "$wall_pat_line" = "none" ]; then
					make_a_contents_obj $x $y $d >>$t
					echo "$x $y $d $((current_obj_id - 1)) $wall_pat" >>$lst
				else
					obj_id=$(echo $wall_pat_line | sed -r 's/^.+obj_id=([0-9]+).+$/\1/')
					echo "$x $y $d $obj_id $wall_pat" >>$lst
				fi
			done
		done
	done

	cat $t
}

make_page_obj_all() {
	local x
	local y
	local d
	local contents_obj_id

	for y in $(seq $height); do
		for x in $(seq $width); do
			for d in $DIRECTION_LIST; do
				contents_obj_id=$(grep "$x $y $d" $WORK_DIR/coord_objid.lst | cut -d' ' -f4)
				echo -e "$current_obj_id 0 obj"
				echo -e "\t<<\t/Type /Page"
				echo -e "\t\t/Parent $PAGES_OBJ_ID 0 R"
				echo -e "\t\t/Annots\t[\t<<\t/Type /Annot"
				echo -e "\t\t\t\t\t/Subtype /Link"
				echo -e "\t\t\t\t\t/Rect [293 213 308 228]"
				echo -e "\t\t\t\t\t/Border [0 0 0]"
				echo -e "\t\t\t\t\t/Dest [17 0 R /Fit]"
				echo -e "\t\t\t\t>>"
				echo -e "\t\t\t]"
				echo -e "\t\t/Contents $contents_obj_id 0 R"
				echo -e "\t>>"
				echo 'endobj'
				echo
				current_obj_id=$((current_obj_id + 1))
			done
		done
	done
}

current_obj_id=$START_OBJ_ID
load_map_attr
make_contents_obj_all
make_page_obj_all
