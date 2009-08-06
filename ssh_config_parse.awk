#!/usr/bin/awk -f

BEGIN { 
	true = 1; 
	false = 0; 
	m = false; 
}



function match_host(line, host) {
	for (i in line)
		if(match(host, line[i])) return true
	return false
}

{
	if( /^Host([ \t])/ ){ 
		offset = 2;
		for (x = offset; x <= NF; x++)
			line[x - offset] = $x
#		print "host:", line[0]
		m = match_host(line, host)
	}else{
		if(m == true && match($1, key)) { print $0;	}
	}



}
