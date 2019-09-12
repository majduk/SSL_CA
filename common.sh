#!/usr/bin/env bash

#config
source $( dirname $0 )/config.conf

certs_dir=~/certs
ca_home=~/certs/ca
openssl_config=$( dirname $0 )/openssl.cnf
CA_KEY=$ca_home/ca.key
CA_CRT=$ca_home/ca.crt
CA_CSR=$ca_home/ca.csr
CA_CRL=$ca_home/ca.crl

export SslCaHome="$ca_home"
export SslCountryName="$COUNTRY_NAME"
export SslStateOrProvinceName="$STATE_NAME"
export SslLocalityName="$CITY_NAME"
export SslOrganizationName="$ORGANIZATION_NAME"
export SslOrganizationalUnitName="$UNIT_NAME"

