#!/usr/bin/env bash
su -
CA_BASE_DIR=/etc/ssl

RECIPIENTS=""
SENDER=""

now=$( date +%s )
DAYS=7
HIGH_D=$(( $DAYS +1))

LOW=$(( $DAYS*24*3600  ))
HIGH=$(( $HIGH_D*24*3600  ))

list=""
#set -x
while read state ts serial1 serial2 name
do
	v_ts=${ts:0:10} 

	if [ $state = "V" ]; then
		t_diff=$(( $v_ts - $now ))
		if [[ $t_diff -gt $LOW && $t_diff -lt $HIGH  ]];then
			cn=$( echo $name | cut -d"/" -f6 )
	 		list="$list $cn"
		fi 
	fi
	#date -d "1970-01-01 00:00 $v_ts seconds" +%Y%m%d
done < $CA_BASE_DIR/private/index.txt

for name in $list; do
	for recipient in $RECIPIENTS; do
		sendsms $SENDER $recipient "Certyfikat dla $name wyekspiruje za $DAYS dni"
	done
done
