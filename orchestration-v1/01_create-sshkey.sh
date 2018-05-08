#!/bin/bash

# source the Oracle Cloud Account info
. ./env.sh

# Creates SSH Key
PUBLICSSHKEY=`cat ~/.ssh/greg.pub | awk '{print $2}'`
opc compute ssh-keys add /Compute-$IDENTITYDOMAIN/$USER/greg $PUBLICSSHKEY
