#!/usr/bin/env bash
    
#config
source $( dirname $0 )/common.sh
export SslCommonName=$CA_NAME

# Generate the key. Encrypted
openssl genrsa -des3 -out $CA_KEY 2048 -config $openssl_config -debug
# Generate a certificate request.
openssl req -new -key $CA_KEY -out $CA_CSR -config $openssl_config

openssl x509 -req -days 3650 -in $CA_CSR -signkey $CA_KEY -out $CA_CRT
# Setup the first serial number for our keys
echo FACE > $base/serial
# Create the CA's key database.
touch $base/index.txt
# Create a Certificate Revocation list for removing 'user certificates.'
openssl ca -gencrl -out $CA_CRL -crldays $CA_CRL_DAYS -config $openssl_config

