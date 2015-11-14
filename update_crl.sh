#!/usr/bin/env bash

source $( dirname $0 )/common.sh
export SslCommonName="dummy-common-name"

fail_if_error() {
    [ $1 != 0 ] && {
        unset PASSPHRASE
        echo "failed";
        exit 10
    }
}

get_ca_password() {
    if [ -z $PASSPHRASE ];then    
      read -s -p "Enter CA key password:" PASSPHRASE;
      export PASSPHRASE
    fi
}

get_ca_password 
echo "Updating CRL..."
openssl ca -gencrl -out $CA_CRL -crldays $CA_CRL_DAYS -config $openssl_config -passin env:PASSPHRASE
fail_if_error $?
echo "done"
echo "Make sure you copy the new CRL file $CA_CRL to web server and restart the web server"

