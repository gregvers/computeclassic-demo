#!/bin/bash

# source the Oracle Cloud Account info
. ./env.sh

# Upload or update orchestrations
# commondefs update
if [[ "$(opc compute orchestrations list /Compute-$IDENTITYDOMAIN/$USER/common)" != *"\"result\": []"* ]] ;
then
	opc compute orchestrations update /Compute-$IDENTITYDOMAIN/$USER/common --request-body=./v1/common.json
else
	opc compute orchestrations add --request-body=./v1/common.json
fi

# natgw update
if [[ "$(opc compute orchestrations list /Compute-$IDENTITYDOMAIN/$USER/natgw)" != *"\"result\": []"* ]] ;
then
	opc compute orchestrations update /Compute-$IDENTITYDOMAIN/$USER/natgw --request-body=./v1/natgw.json
else
	opc compute orchestrations add --request-body=./v1/natgw.json
fi

# jumphost update
if [[ "$(opc compute orchestrations list /Compute-$IDENTITYDOMAIN/$USER/jumphost)" != *"\"result\": []"* ]] ;
then
	opc compute orchestrations update /Compute-$IDENTITYDOMAIN/$USER/jumphost --request-body=./v1/jumphost.json
else
	opc compute orchestrations add --request-body=./v1/jumphost.json
fi

# lbr update
if [[ "$(opc compute orchestrations list /Compute-$IDENTITYDOMAIN/$USER/lbr)" != *"\"result\": []"* ]] ;
then
	opc compute orchestrations update /Compute-$IDENTITYDOMAIN/$USER/lbr --request-body=./v1/lbr.json
else
	opc compute orchestrations add --request-body=./v1/lbr.json
fi

# apps update
if [[ "$(opc compute orchestrations list /Compute-$IDENTITYDOMAIN/$USER/apps)" != *"\"result\": []"* ]] ;
then
	opc compute orchestrations update /Compute-$IDENTITYDOMAIN/$USER/apps --request-body=./v1/apps.json
else
	opc compute orchestrations add --request-body=./v1/apps.json
fi

# db update
if [[ "$(opc compute orchestrations list /Compute-$IDENTITYDOMAIN/$USER/db)" != *"\"result\": []"* ]] ;
then
	opc compute orchestrations update /Compute-$IDENTITYDOMAIN/$USER/db --request-body=./v1/db.json
else
	opc compute orchestrations add --request-body=./v1/db.json
fi

# master update
if [[ "$(opc compute orchestrations list /Compute-$IDENTITYDOMAIN/$USER/master)" != *"\"result\": []"* ]] ;
then
	opc compute orchestrations update /Compute-$IDENTITYDOMAIN/$USER/master --request-body=./v1/master.json
else
	opc compute orchestrations add --request-body=./v1/master.json
fi
