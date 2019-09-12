#!/usr/bin/env bash

source $( dirname $0 )/common.sh

while IFS= read -r server;do
    $( dirname $0)/new_server.sh $server
done < $SERVICE_LIST
