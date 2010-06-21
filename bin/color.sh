#!/bin/bash

# http://www.termsys.demon.co.uk/vtansi.htm
main (){
local v= s=
for i in $@ end; do
	if [ ! -z $v ]; then
		[ $i = 'bg' ] && v=$(( v + 10 ));
		[ -z $s ] || s="$s;"
		s="$s$v"
		[ $i = 'bg' ] && continue;
	fi
	case $i in
		none|reset) v=0;;
		bright|bold) v=1;;
		dim) v=2;;
		underscore|underline) v=4;;
		blink) v=5;;
		reverse) v=7;;
		hidden) v=8;;
		black) v=30;;
		red)  v=31;;
		green) v=32;;
		yellow) v=33;;
		blue) v=34;;
		magenta) v=35;;
		cyan) v=36;;
		white) v=37;;
		end) break;;
	esac	
done
echo -e -n "\033[${s}m"
}


main $@
