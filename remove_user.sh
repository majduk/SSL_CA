#!/usr/bin/env bash

# Revoke a certificate and update the CRL.

if [ "$1" = "" ]; then
  echo "Usage: $0 username"
  exit 11
else
 comName=$1 
fi

#config
source $( dirname $0 )/common.sh
export SslCommonName=$comName

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

Yes_No ()
{
  question="$1"
  ret="0"
  # print question
  echo -n $question

  # read answer
  read YnAnswer

  # all to lower case
  YnAnswer=$(echo $YnAnswer | awk '{print tolower($0)}')

  # check and act on given answer
  case $YnAnswer in
    "yes")  ret="1" ;;
    "no")   ret="0" ;;
	*)  echo "Please answer yes or no" ; Yes_No ;;
  esac
  return $ret
}

#Locate file to revoke
USER_SERIAL=$( grep '^V' $base/index.txt | grep "CN=$comName$"  | head -n 1 | cut -f 4 )
test -z $USER_SERIAL && echo "CommonName $comName not found" && exit 1

USER_PEM=$base/$USER_SERIAL.pem
if [ -f $USER_PEM ]; then  
  echo -n "Found following "
  openssl x509 -noout -in $USER_PEM  -text
  Yes_No "Revoke this certificate? [yes/no]:"
  if [ "$?" -eq "1" ]; then
    get_ca_password    
    echo "Revoking certificate for user CN=$comName (serial $USER_SERIAL)..." 
    openssl ca -revoke $USER_PEM -config $openssl_config -passin env:PASSPHRASE
    fail_if_error $?
    echo "done"

    $( dirname $0 )/update_crl.sh

  else
  	echo "Revoke cancelled"          
  fi
else
  echo "PEM file $USER_PEM not found"
  exit 2
fi
