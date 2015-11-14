#!/usr/bin/env bash

usage="Usage: $0 msisdn password"

user=${1:? $usage }
pass=${2:? $usage }

wget --no-proxy --output-document=/dev/null "http://kannel:80/cgi-bin/sendsms?username=${smsuse}&password=${smspass}&from=${from}&to=${user}&text=${pass}"

