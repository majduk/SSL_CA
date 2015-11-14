#!/usr/bin/env bash

#config
source $( dirname $0 )/common.sh

mkdir -p $public_dir
chown root:$CA_GROUP $public_dir
chmod 770 $public_dir
chmod g+s $public_dir

dest_dir=$public_dir

if [ -d $dest_dir ]; then
	echo -n "Copying CRL $( basename $CA_CRL ) ...";
	cp $CA_CRL $dest_dir
	chown root:$CA_GROUP $dest_dir/$( basename $CA_CRL )
	chmod 660 $dest_dir/$( basename $CA_CRL )
	echo "done";
	echo "Move file from $dest_dir to the server and restart the server"
else
	echo "No such  directory: $dest_dir";  
	exit 1
fi
