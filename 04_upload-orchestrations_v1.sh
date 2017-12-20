#!/bin/bash

# source the Oracle Cloud Account info
. ./env.sh

# Upload or update orchestrations
# commondefs update
if [[ "$(opc compute orchestrations list /Compute-$IDENTITYDOMAIN/$USER/commondefs)" != *"\"result\": []"* ]] ;
then
	opc compute orchestrations update /Compute-$IDENTITYDOMAIN/$USER/commondefs --request-body=./v1/commondefs_v1.json
else
	opc compute orchestrations add --request-body=./v1/common_v1.json
fi

# natgw update
if [[ "$(opc compute orchestrations list /Compute-$IDENTITYDOMAIN/$USER/natgw)" != *"\"result\": []"* ]] ;
then
	opc compute orchestrations update /Compute-$IDENTITYDOMAIN/$USER/natgw --request-body=./v1/natgw_v1.json
else
	opc compute orchestrations add --request-body=./v1/natgw_v1.json
fi

# jumphost update
if [[ "$(opc compute orchestrations list /Compute-$IDENTITYDOMAIN/$USER/jumphost)" != *"\"result\": []"* ]] ;
then
	opc compute orchestrations update /Compute-$IDENTITYDOMAIN/$USER/jumphost --request-body=./v1/jumphost_v1.json
else
	opc compute orchestrations add --request-body=./v1/jumphost_v1.json
fi

# lbr update
if [[ "$(opc compute orchestrations list /Compute-$IDENTITYDOMAIN/$USER/lbr)" != *"\"result\": []"* ]] ;
then
	opc compute orchestrations update /Compute-$IDENTITYDOMAIN/$USER/lbr --request-body=./v1/lbr_v1.json
else
	opc compute orchestrations add --request-body=./v1/lbr_v1.json
fi

# apps update
if [[ "$(opc compute orchestrations list /Compute-$IDENTITYDOMAIN/$USER/apps)" != *"\"result\": []"* ]] ;
then
	opc compute orchestrations update /Compute-$IDENTITYDOMAIN/$USER/apps --request-body=./v1/apps_v1.json
else
	opc compute orchestrations add --request-body=./v1/apps_v1.json
fi

# db update
if [[ "$(opc compute orchestrations list /Compute-$IDENTITYDOMAIN/$USER/db)" != *"\"result\": []"* ]] ;
then
	opc compute orchestrations update /Compute-$IDENTITYDOMAIN/$USER/db --request-body=./v1/db_v1.json
else
	opc compute orchestrations add --request-body=./v1/db_v1.json
fi

# master update
if [[ "$(opc compute orchestrations list /Compute-$IDENTITYDOMAIN/$USER/master)" != *"\"result\": []"* ]] ;
then
	opc compute orchestrations update /Compute-$IDENTITYDOMAIN/$USER/master --request-body=./v1/master_v1.json
else
	opc compute orchestrations add --request-body=./v1/master_v1.json
fi
