#!/usr/bin/env bash
#config
set -e
source $( dirname $0 )/common.sh
echo "---- $1 ----"
SERVER=$1
SERVER_KEY=$certs_dir/${SERVER}.key
SERVER_CSR=$certs_dir/${SERVER}.csr
SERVER_CRT=$certs_dir/${SERVER}.crt

fail_if_error() {
    [ $1 != 0 ] && {
        echo "failed";
        exit 10
    }
}

echo -n "Generating Private Key file...";
openssl genrsa -out $SERVER_KEY
echo "done";

echo -n "Creating Certificate Request file...";
export SslCommonName=$SERVER
export SslAltName=$SERVER
req_exts="-reqexts req_alt_name"
ca_exts="-extensions req_alt_name"

openssl req \
    -new \
    -batch \
    -key $SERVER_KEY \
    -out $SERVER_CSR \
    -config $openssl_config \
    $req_exts
echo "done";

echo "Signing Certificate Request file...";
openssl ca -batch -in $SERVER_CSR -cert $CA_CRT -keyfile $CA_KEY -out $SERVER_CRT -config $openssl_config $ca_exts
echo "done";

