#!/bin/bash

# source the Oracle Cloud Account info
. ./env.sh

# Orchestration startup
opc compute orchestrations update /Compute-$IDENTITYDOMAIN/$USER/master --action START
