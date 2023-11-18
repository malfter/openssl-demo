#!/usr/bin/env bash

MY_CERT=myserver
MY_CERT_COMMON_NAME="My Server"
MY_CERT_COUNTRY_NAME=DE
MY_CERT_STATE=NRW
MY_CERT_LOCALITY_NAME=Troisdorf
MY_CERT_ORG_NAME=MyOrg
MY_CERT_ORG_UNIT_NAME="IT Unit"
MY_CERT_EMAIL=admin@myserver.de

mkdir $MY_CERT
cd $MY_CERT || exit

openssl req -new -nodes -out ${MY_CERT}.csr -newkey rsa:4096 -keyout ${MY_CERT}.key \
  -subj "/CN=${MY_CERT_COMMON_NAME}/C=${MY_CERT_COUNTRY_NAME}/ST=${MY_CERT_STATE}/L=${MY_CERT_LOCALITY_NAME}/O=${MY_CERT_ORG_NAME}/OU=${MY_CERT_ORG_UNIT_NAME}/emailAddress=${MY_CERT_EMAIL}"

# create a v3 ext file for SAN properties
#
# The v3.ext file contains the properties of the v3 extension of certificates.
# This includes especially the SAN (subject alternative names) which contains
# the information about DNS or IP, which the browser needs to trust the
# certificate (you somehow need to make sure, that mysite.local uses the
# certificate that was issued for mysite.local)
cat > "${MY_CERT}.v3.ext" << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = myserver.local
DNS.2 = myserver1.local
IP.1 = 192.168.1.1
IP.2 = 192.168.2.1
EOF
