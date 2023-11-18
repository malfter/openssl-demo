#!/usr/bin/env bash

CA_NAME=MyOrg-RootCA

cd $CA_NAME || exit

# 5 years = 1826 days
_5_YEARS=1826

CA_COMMON_NAME="MyOrg Root CA"
CA_COUNTRY_NAME=DE
CA_STATE=NRW
CA_LOCALITY_NAME=Troisdorf
CA_ORG_NAME=MyOrg
CA_ORG_UNIT_NAME="Some Unit"
CA_EMAIL=admin@myorg.de

openssl req -x509 -new -nodes -key "${CA_NAME}.key" -sha256 -days "$_5_YEARS" -out "${CA_NAME}.crt" \
  -subj "/CN=${CA_COMMON_NAME}/C=${CA_COUNTRY_NAME}/ST=${CA_STATE}/L=${CA_LOCALITY_NAME}/O=${CA_ORG_NAME}/OU=${CA_ORG_UNIT_NAME}/emailAddress=${CA_EMAIL}"
