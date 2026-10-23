#!/usr/bin/env bash
set -euo pipefail

CA_NAME=MyOrg-RootCA

# Never overwrite an existing CA (and its private key)
if [ -e "${CA_NAME}" ]; then
  echo "[ERROR] '${CA_NAME}' already exists, refusing to overwrite the CA key" >&2
  exit 1
fi

mkdir "${CA_NAME}"
cd "${CA_NAME}"

echo "[INFO] Generate aes encrypted private key"
echo
echo "We will encrypt the key with AES because if anyone gets access to the key this"
echo "person can create signed, trusted certificates. Encrypting the key adds some"
echo "protection (use a 20+ password)."
echo
openssl genrsa -aes256 -out "${CA_NAME}.key" 4096
