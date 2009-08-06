#!/bin/bash

export SQL_CONN='';

function sql () {
	[ -z "$SQL_CONN" ] && {
		local user= host= db= pass=;
		read -p "Host: " host; [ -z "$host" ] || SQL_CONN="${SQL_CONN} -h $host";
		read -p "User: " user; [ -z "$user" ] || SQL_CONN="${SQL_CONN} -u $user";
		read -p "Database: " db; [ -z "$db" ] || SQL_CONN="${SQL_CONN} -D $db";
		read -p "Ask pass? [y/n]" pass; [ "$pass" = 'n' ] || SQL_CONN="${SQL_CONN} -p";
		export SQL_CONN;
	}

	case $1 in
		triggers) case $2 in
			expose|insert) v=$2; shift 2; sql.triggers_$v "$SQL_CONN" $@;;
		esac;;
	esac
}

function sql.triggers_insert () {
	conn=$1; shift;
	cat $@ | mysql $conn
}

function sql.triggers_expose () { # args: connection info for mysql, e.g. -u user, host, database
	temporary=$(mktemp);
	echo 'SHOW TRIGGERS;' | mysql $1 -N > $temporary;

	count=`wc -l ${temporary} | awk '{print $1}'`
	echo "-- triggers received from: SHOW TRIGGERS on $@ [${count}]";

	delimiter="$//"
	echo -e "DELIMITER ${delimiter}\n\n"

	awkscript=$(mktemp);

	cat > $awkscript <<-EOF
	BEGIN {FS=":::";} { 
		gsub(/\\\n/,"\n", \$4); gsub(/\\\t/,"\t",\$4); 
	printf("DROP TRIGGER IF EXISTS %s; ${delimiter} \nCREATE TRIGGER %s %s %s ON %s \nFOR EACH ROW %s; ${delimiter}\n\n\n",
		\$1, \$1, \$5, \$2, \$3, \$4);
	}
	EOF


	# parse the output
	cat ${temporary} | cut -f1,2,3,5,4 --output-delimiter=":::" | awk -f ${awkscript} 
	
	echo -e "\n\nDELIMITER ;\n"

	rm $temporary $awkscript
}



