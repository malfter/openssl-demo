# Create a certificate authority with OpenSSL

In this repository you will find some scripts to create a certificate authority for testing or to create your own (simple) private CA.

## Table of Contents

- [Create a certificate authority with OpenSSL](#create-a-certificate-authority-with-openssl)
  - [Table of Contents](#table-of-contents)
  - [Create CA and End-user Certificate](#create-ca-and-end-user-certificate)
  - [Overview about generated files](#overview-about-generated-files)
  - [Checking generated files](#checking-generated-files)
    - [Debugging with OpenSSL](#debugging-with-openssl)
  - [Cleanup](#cleanup)
  - [Further Informations](#further-informations)

## Create CA and End-user Certificate

```bash
./1-createPrivateKeyForCA.sh

./2-createCertificateOfCA.sh

# Optional: only prints commands; does not change your system.
./3-addCACertToTrustedRootCAs.sh

# Creates a certificate for 'myserver'.
./4-createCertificateForServer.sh

# Sign the created certificate with the created CA.
./5-signCertificate.sh
```

Installing the CA in your operating system's trust store is optional. Running the
commands printed by step 3 changes system-wide trust and may require administrator
privileges. For the checks below, use `-CAfile` to trust this CA explicitly without
changing the system trust store. Keep the CA private key private; distribute only
the CA certificate to clients that should trust it.

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

Run these commands from the repository root after creating the demo certificates.
The examples below use OpenSSL 3.x.

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

The CSR check verifies its own signature, not whether a CA has issued a trusted
certificate for it.

Verify the server certificate against the demo CA, including validity, server
certificate purpose and the expected DNS name:

```bash
openssl verify -CAfile MyOrg-RootCA/MyOrg-RootCA.crt \
  -purpose sslserver -verify_hostname myserver.local myserver/myserver.crt
```

Expected result: `myserver/myserver.crt: OK`. This is an offline certificate check;
it does not establish a connection or check certificate revocation.

### Debugging with OpenSSL

Compare SHA-256 digests of the public key in the certificate, private key and CSR.
Each command converts the public key to the same DER format before hashing it.
This works for RSA and EC keys, unlike an RSA-specific modulus comparison:

```bash
openssl x509 -in myserver/myserver.crt -pubkey -noout \
  | openssl pkey -pubin -outform DER | openssl dgst -sha256
openssl pkey -in myserver/myserver.key -pubout -outform DER \
  | openssl dgst -sha256
openssl req -in myserver/myserver.csr -pubkey -noout \
  | openssl pkey -pubin -outform DER | openssl dgst -sha256
```

All three digests must match. This only establishes that the public keys match;
it does not verify certificate trust or identity. Check every command for errors;
when scripting pipelines in Bash, enable `set -o pipefail` so an earlier failure
is not hidden by a successful hashing command.

The scripts above only generate files; they do not start a server. To try the
following connection examples, start a simple local HTTPS test server from the
repository root:

```bash
openssl s_server -accept 127.0.0.1:8443 \
  -cert myserver/myserver.crt \
  -key myserver/myserver.key \
  -www
```

`-www` serves a basic HTTP test page over TLS. The server listens only on the
local loopback address and uses an unprivileged port, so no administrator rights
are required. Leave it running and execute the client commands in a second
terminal, also from the repository root. Stop the server with `Ctrl+C` when done.
If port 8443 is already in use, choose another unused port in both the server
and client commands; do not stop unrelated processes.

The clients connect to `127.0.0.1:8443` but use `myserver.local` for SNI and
certificate hostname verification. No DNS or hosts-file changes are needed.
This is a diagnostic server, not a production web server. Only test endpoints
you own or are authorized to inspect.

Inspect the certificates sent by the server:

```bash
openssl s_client -connect 127.0.0.1:8443 \
  -servername myserver.local -showcerts </dev/null
```

`-servername` sends the SNI name so a server hosting multiple sites can select
the intended certificate. It does not enable hostname verification. `-showcerts`
displays the list sent by the server, not a verified or necessarily complete
chain. The root CA is normally omitted. By default, `s_client` reports certificate
verification errors but can continue; a completed handshake alone is not proof
of a trusted server identity.

Require successful certificate verification and check the expected hostname:

```bash
openssl s_client -connect 127.0.0.1:8443 \
  -servername myserver.local \
  -CAfile MyOrg-RootCA/MyOrg-RootCA.crt \
  -verify_hostname myserver.local -verify_return_error -brief </dev/null
```

`-CAfile` supplies the trusted demo CA, `-verify_hostname` checks the DNS identity,
and `-verify_return_error` aborts on certificate verification errors. Check the
verification result as well as the process exit status; unrelated transport or
shutdown errors may also produce a nonzero exit status. `-brief` includes the
negotiated TLS version and cipher suite, not all combinations the server supports.

To make a complete HTTPS request and display the test page, use curl (if installed):

```bash
curl --noproxy '*' \
  --resolve myserver.local:8443:127.0.0.1 \
  --cacert MyOrg-RootCA/MyOrg-RootCA.crt \
  https://myserver.local:8443/
```

`--resolve` sets the destination address for this request while preserving
`myserver.local` as the SNI and certificate verification name. `--cacert` trusts
the demo CA explicitly, and `--noproxy '*'` bypasses configured proxies for this
local test. Unlike `curl -k`, this keeps certificate verification enabled.

Inspect Subject Alternative Names (SANs) in the local server certificate:

```bash
openssl x509 -in myserver/myserver.crt -noout -ext subjectAltName
```

Displaying SANs is not a hostname check. Use `-verify_hostname` as shown above
to verify the expected DNS name against the certificate.

## Cleanup

Stop any running test server with `Ctrl+C` before cleaning up. To delete the
generated files, run the [cleanup script](cleanup.sh):

```bash
./cleanup.sh
```

## Further Informations

- [https://www.feistyduck.com/books/openssl-cookbook/]
- [https://arminreiter.com/2022/01/create-your-own-certificate-authority-ca-using-openssl/]
- [https://gist.github.com/cbj4074/ab5826395e940ffc202dcb11004daa54]
- [https://www.sslshopper.com/article-most-common-openssl-commands.html]
