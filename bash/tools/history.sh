#!/bin/bash


history_script () {
	[ $# -ne 1 ] && echo "usage: history | history_script \$outfile" && return 0

	(
	echo '#!/bin/bash'
	cut -d ' ' -f 5-
	) > $1
}
