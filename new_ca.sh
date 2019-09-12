#!/usr/bin/env bash
set -e
#config
source $( dirname $0 )/common.sh
mkdir -p ${certs_dir}
mkdir -p ${SslCaHome}
export SslCommonName=$CA_NAME
export SslAltName=$CA_NAME


# Generate the key. Not Encrypted
openssl genrsa -out $CA_KEY 2048
# Generate a certificate request.
openssl req -new -key $CA_KEY -out $CA_CSR -config $openssl_config

openssl x509 -req -days 3650 -in $CA_CSR -signkey $CA_KEY -out $CA_CRT
# Setup the first serial number for our keys
echo FACE > $SslCaHome/serial
# Create the CA's key database.
touch $SslCaHome/index.txt
touch $SslCaHome/index.txt.attr
# Create a Certificate Revocation list for removing 'user certificates.'
openssl ca -gencrl -key $CA_KEY -out $CA_CRL -crldays $CA_CRL_DAYS -config $openssl_config
cp $CA_CRT $certs_dir/
