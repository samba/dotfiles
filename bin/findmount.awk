#!/usr/bin/awk -f

BEGIN { 
	longestpath = ""
	mountpoint = ""
}


{
	i = index(path, $2)
	l = length(longestpath)
	k = length($2)
	if(i == 1 && k > l){
		longestpath = $2;
		mountpoint = $1;
	}
}


END {
	print mountpoint;
}
