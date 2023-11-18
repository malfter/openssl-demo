#!/usr/bin/env bash

CA_NAME=MyOrg-RootCA

echo "[INFO] Execute the following commands to add the CA certificate"
echo "       to the trusted root CAs in your Linux system:"
echo
echo "# Debian/Ubuntu"
echo "sudo apt install -y ca-certificates"
echo "sudo cp "${CA_NAME}/${CA_NAME}.crt" /usr/local/share/ca-certificates"
echo "sudo update-ca-certificates"
echo
echo "# Feora/CentOS"
echo "sudo cp "${CA_NAME}/${CA_NAME}.crt" /etc/pki/ca-trust/source/anchors/${CA_NAME}.crt"
echo "sudo update-ca-trust"
