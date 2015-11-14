#!/usr/bin/env bash

if [ "$1" = "" ]; then
  echo "Usage: $0 username [dest dir]"
  exit 11
else
 comName=$1
fi

#config
source $( dirname $0 )/common.sh

mkdir -p $public_dir
chown root:$CA_GROUP $public_dir
chmod 770 $public_dir
chmod g+s $public_dir

dest_dir=$public_dir

if [ -d $dest_dir ]; then
	echo -n "Copying Server Private Key $( basename $USER_PACK ) to $dest_dir...";
	cp $USER_PACK $dest_dir
        chown root:$CA_GROUP $dest_dir/$( basename $USER_PACK )
        chmod 660 $dest_dir/$( basename $USER_PACK )
	echo "done";
else
	echo "No such  directory: $dest_dir";  
	exit 1
fi
