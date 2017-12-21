#!/bin/bash

# endpoint, account and user
export IDENTITYDOMAIN=computepm
export USER=gregory.verstraeten@oracle.com
export PASSWORD=""

# sitec/computepm
export COMPUTE_ENDPOINT=http://10.252.131.38:7777
export STORAGE_AUTH_ENDPOINT=http://$IDENTITYDOMAIN.devpool0.opcstorage.com:7820/auth/v1.0
export STORAGE_ENDPOINT=http://$IDENTITYDOMAIN.devpool0.opcstorage.com:7820/v1/Storage-$IDENTITYDOMAIN

# US2/computepm
#export COMPUTE_ENDPOINT=https://api-z64.compute.us6.oraclecloud.com
#export STORAGE_AUTH_ENDPOINT=https://$IDENTITYDOMAIN.storage.oraclecloud.com/auth/v1.0
#export STORAGE_ENDPOINT=https://$IDENTITYDOMAIN.storage.oraclecloud.com/v1/Storage-$IDENTITYDOMAIN

# Proxy setting (if needed)
export HTTPS_PROXY=https://www-proxy.us.oracle.com:80
export HTTP_PROXY=http://www-proxy.us.oracle.com:80
export http_proxy=http://www-proxy.us.oracle.com:80
export https_proxy=https://www-proxy.us.oracle.com:80
