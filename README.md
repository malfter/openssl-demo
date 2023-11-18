# Create a certificate authority with OpenSSL

In this repository you will find some scripts to create a certificate authority for testing or to create your own (simple) private CA.

## Table of Contents

- [Create a certificate authority with OpenSSL](#create-a-certificate-authority-with-openssl)
  - [Table of Contents](#table-of-contents)
  - [Create CA and End-user Certificate](#create-ca-and-end-user-certificate)
  - [Overview about generated files](#overview-about-generated-files)
  - [Checking generated files](#checking-generated-files)
    - [Debugging with OpenSSL](#debugging-with-openssl)
  - [Further Informations](#further-informations)

## Create CA and End-user Certificate

```bash
./1-createPrivateKeyForCA.sh

./2-createCertificateOfCA.sh

# Only shows the commands to be executed, the script will not change your system.
./3-addCACertToTrustedRootCAs.sh

# Creates a certificate for 'myserver'.
./4-createCertificateForServer.sh

# Sign the created certificate with the created CA.
./5-signCertificate.sh
```

## Overview about generated files

The above scripts generate the following files:

```sh
.
├── MyOrg-RootCA
│   ├── MyOrg-RootCA.crt # CA certificate
│   ├── MyOrg-RootCA.key # CA private Key
│   └── MyOrg-RootCA.srl # CA serial file (with a HEX value,
|                        # OpenSSL uses this file to track the
|                        # serial numbers of certificates it creates)
└── myserver
    ├── myserver.crt     # Certificate signed by CA
    ├── myserver.csr     # Certificate signing request
    ├── myserver.key     # Private key for myserver
    └── myserver.v3.ext  # file contains the properties
                         # of the v3 extension of certificates
```

## Checking generated files

Check CA Certificate:

```bash
openssl x509 -in MyOrg-RootCA/MyOrg-RootCA.crt -text -noout
```

Check myserver Certificate:

```bash
openssl x509 -in myserver/myserver.crt -text -noout
```

Check myserver Certificate Signing Request:

```bash
openssl req -text -noout -verify -in myserver/myserver.csr
```

### Debugging with OpenSSL

Check a MD5 hash of the public key to ensure that it matches with what is in a CSR or private key:

```bash
openssl x509 -noout -modulus -in myserver/myserver.crt | openssl md5
openssl rsa -noout -modulus -in myserver/myserver.key | openssl md5
openssl req -noout -modulus -in myserver/myserver.csr | openssl md5
```

Check a SSL connection. All the certificates (including Intermediates) should be displayed:

```bash
openssl s_client -connect myserver.de:443
```

CheckSubject Alternative Names:

```bash
openssl s_client -connect alfter-web.de:443 </dev/null 2>/dev/null \
  | openssl x509 -noout -text | grep DNS:
```

## Further Informations

- [https://www.feistyduck.com/books/openssl-cookbook/]
- [https://arminreiter.com/2022/01/create-your-own-certificate-authority-ca-using-openssl/]
- [https://gist.github.com/cbj4074/ab5826395e940ffc202dcb11004daa54]
- [https://www.sslshopper.com/article-most-common-openssl-commands.html]
