#!/usr/bin/env bash

CA_NAME=MyOrg-RootCA

MY_CERT=myserver
MY_CERT_DAYS=30 # days

openssl x509 -req \
  -in "${MY_CERT}/${MY_CERT}.csr" \
  -CA "${CA_NAME}/${CA_NAME}.crt" \
  -CAkey "${CA_NAME}/${CA_NAME}.key" \
  -CAcreateserial \
  -out "${MY_CERT}/${MY_CERT}.crt" \
  -days "${MY_CERT_DAYS}" \
  -sha256 \
  -extfile "${MY_CERT}/${MY_CERT}.v3.ext"
