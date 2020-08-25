#!/bin/bash

# set -uex
set -ue

utf8_to_unicode() {
	echo $(echo -en "$1" | nkf -W -w32B0 | xxd -ps -c4 | cut -c5-)
}

ch="$1"
font_size=$2

fnum_chnum_unicode=$(awk "tolower(\$3)==\"$(utf8_to_unicode ${ch})\"{print \$0}" tounicode.map)

fnum=$(echo $fnum_chnum_unicode | cut -d' ' -f1)
chnum=$(echo $fnum_chnum_unicode | cut -d' ' -f2)

echo "/${fnum} ${font_size} Tf<${chnum}>Tj"
