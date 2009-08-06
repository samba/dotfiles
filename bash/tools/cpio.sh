#!/bin/bash

function s.mkcpio () {
	o=$(pwd)
	for i in $@; do
		cd $i
		find | cpio -H newc -o | gzip > "$o/$(basename $i).[$(date +%D-%T | tr '/:' '..')].img"
		cd $OLDPWD
	done
}


function s.cpio () {
	declare verb= numinput=0 input= output= loud= exclude=$(mktemp)
	OPTIND=1
	while getopts :e:i:o:xvc Option; do
		case $Option in
			i) input="${input} $OPTARG"; numinput=$((numinput + 1));;
			o) output="$OPTARG";;
			c|x) verb=$Option;;
			e) echo ${OPTARG} >> $exclude;;
			v) loud=yes;;
		esac
	done
	
	# default values	
	case $verb in
		c) input=${input:-./}; 
			if [ "$input" = './' ]; then 
				output=${output:-../$(basename `pwd`).cpio.gz};
			elif [ $numinput -eq 1 ]; then	
				output=${output:-`dirname ${input}`/`basename ${input}`.cpio.gz}; 
			else [ -z $output ] && echo "Must specify output when using multiple sources.">&2 && return 2;
			fi
		;;
		x) output=${output:-`pwd`}; 
			[ -z $input ] && echo "Extraction requires input!">&2 && return 1;
			;;
	esac



	# action
	output=$(readlink -f $output)
	case $verb in
		c)  echo "Producing $output from $input"; 
		    files=$(mktemp) grepargs=''
		    
		    goOLDPWD=n
		    if [ $(echo $input | wc -w | awk '{ print $1 }') -eq 1 ]; then 
			cd $input
			goOLDPWD=y
			input='.'
		    fi

		    find $input > $files
		    if [ -n $exclude ]; then
			echo "Exclusions from: $exclude"
			while read ex; do
			    echo "Excluding: $ex"
			    sed -i "/$ex/d" $files
			done < $exclude
		    else
			echo "Nothing excluded. ($exclude)"
		    fi
		    
		    cat $files | cpio -H newc -o | gzip > $output

		    [ $goOLDPWD = 'y' ] && cd $OLDPWD
		;;
		x)  echo "Extracting $input to $output"; 
			input=`readlink -f $input`;
			cd $output; zcat -S "" $input | cpio -id; cd $OLDPWD ;;
		*)  s.cpio.usage;;
	esac
	
		
}

function s.cpio.usage () {
cat <<EOF
	s.cpio: usage
	s.cpio -c -i <source dir> -o <dest file.gz>	    create a cpio image (initrd)
	s.cpio -x -i <source file.gz> -o <dest dir>	    extract a cpio image

	s.cpio: defaults
		in create mode:	    input=<dirname>		output=<dirname>.img.gz
		in extract mode:    input (required!)	output=./
EOF

}
