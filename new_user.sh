#!/usr/bin/env bash
          
if [ "$1" = "" ]; then
  echo "Usage: $0 username"
  exit 11
else
 comName=$1 
fi

source $( dirname $0 )/common.sh

randpass() {
  CHAR="[:alnum:]" || CHAR="[:graph:]"
    cat /dev/urandom | tr -cd "$CHAR" | head -c ${1:-16}
    echo
}

fail_if_error() {
    [ $1 != 0 ] && {
        unset PASSPHRASE
        echo "failed";
        exit 10
    }
}

export PASSPHRASE=$( randpass )
mkdir -p $user_base

export SslCommonName=$comName

echo -n "Generating Private Key file...";
openssl genrsa -des3 -out $USER_KEY -passout env:PASSPHRASE 2048 -config $openssl_config
fail_if_error $?
echo "done";

echo -n "Creating Certificate Request file...";
openssl req \
    -new \
    -batch \
    -key $USER_KEY \
    -out $USER_CSR \
    -passin env:PASSPHRASE \
    -config $openssl_config

fail_if_error $?
echo "done";

echo "Signing Certificate Request file...";
openssl ca -in $USER_CSR -cert $CA_CRT -keyfile $CA_KEY -out $USER_CRT -config $openssl_config
fail_if_error $?
echo "done";

echo -n "Exporting certificate...";       
openssl pkcs12 -passout env:PASSPHRASE -export -clcerts -passin env:PASSPHRASE -in $USER_CRT -inkey $USER_KEY -out $USER_P12 
fail_if_error $?

tar -czf $USER_PACK -C $( dirname $USER_P12 ) $( basename $USER_P12 ) -C $( dirname $CA_CRT ) $( basename $CA_CRT )
echo "done";

echo "Certificate stored to $USER_PACK" 
echo "Export password:" $PASSPHRASE

 

