#!/usr/bin/env bash

#config
source $( dirname $0 )/common.sh

mkdir -p $public_dir
chown root:$CA_GROUP $public_dir
chmod 770 $public_dir
chmod g+s $public_dir

dest_dir=$public_dir

if [ -d $dest_dir ]; then
	echo -n "Copying Server Private Key $( basename $SERVER_KEY ) ...";
	cp $SERVER_KEY $dest_dir
	chown root:$CA_GROUP $dest_dir/$( basename $SERVER_KEY )
	chmod 660 $dest_dir/$( basename $SERVER_KEY )
	echo "done";
        echo -n "Copying Server Certificate $( basename $SERVER_CRT )...";
        cp $SERVER_CRT $dest_dir
        chown root:$CA_GROUP $dest_dir/$( basename $SERVER_CRT )
        chmod 660 $dest_dir/$( basename $SERVER_CRT )
        echo "done";
	echo "Move files from $dest_dir to the server and restart the server"
else
	echo "No such  directory: $dest_dir";  
	exit 1
fi
