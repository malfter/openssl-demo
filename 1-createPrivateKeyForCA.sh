#!/usr/bin/env bash

CA_NAME=MyOrg-RootCA

mkdir $CA_NAME
cd $CA_NAME || exit

echo "[INFO] Generate aes encrypted private key"
echo
echo "We will encrypt the key with AES because if anyone gets access to the key this"
echo "person can create signed, trusted certificates. Encrypting the key adds some"
echo "protection (use a 20+ password)."
echo
openssl genrsa -aes256 -out $CA_NAME.key 4096
