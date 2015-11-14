#!/usr/bin/env bash
    
#config
source $( dirname $0 )/common.sh

runtime=$( date +%Y%m%d%H%M%S )

backup_file()
{
  if [ -f $1 ]; then
    cp $1 ${1}.${runtime}
  fi
}

fail_if_error() {
    [ $1 != 0 ] && {
        echo "failed";
        exit 10
    }
}

echo -n "Generating Private Key file...";
backup_file $SERVER_KEY
openssl genrsa -out $SERVER_KEY
fail_if_error $?
echo "done";

echo -n "Creating Certificate Request file...";
backup_file $SERVER_CSR

export SslCommonName=$SERVER_DOMAIN

export SslCountryName=$COUNTRY_NAME
export SslStateOrProvinceName=$STATE_NAME
export SslLocalityName=$CITY_NAME
export SslOrganizationName=$ORGANIZATION_NAME
export SslOrganizationalUnitName=$UNIT_NAME

if [ -n $SERVER_ALT_NAME ];then
	export SslAltName=$SERVER_ALT_NAME
	req_exts="-reqexts req_alt_name"
	ca_exts="-extensions req_alt_name"
fi

openssl req \
    -new \
    -batch \
    -key $SERVER_KEY \
    -out $SERVER_CSR \
    -config $openssl_config \
    $req_exts

fail_if_error $?
echo "done";

echo "Signing Certificate Request file...";
backup_file $SERVER_CRT
openssl ca -in $SERVER_CSR -cert $CA_CRT -keyfile $CA_KEY -out $SERVER_CRT -config $openssl_config $ca_exts
fail_if_error $?
echo "done";

echo "Log in to your server and update CRT $( basename $SERVER_CRT ) and KEY $( basename $SERVER_KEY ) files ";
