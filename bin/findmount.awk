#!/usr/bin/awk -f

# USAGE: findmount.awk -v path=/path/to/your/file /proc/mounts


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
