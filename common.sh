#!/usr/bin/env bash

#config
source $( dirname $0 )/paths.cnf

export SslCountryName=$COUNTRY_NAME
export SslStateOrProvinceName=$STATE_NAME
export SslLocalityName=$CITY_NAME
export SslOrganizationName=$ORGANIZATION_NAME
export SslOrganizationalUnitName=$UNIT_NAME

if [ -n $SslAltName ];then
	export SslAltName="dummy-ssl-alt-name"
fi
