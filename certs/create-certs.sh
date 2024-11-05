#!/bin/bash

########################################################################
# A script to create development certificates used for local development
########################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Fail on first error
#
set -e

#
# Point to the OpenSsl configuration file for the platform
#
case "$(uname -s)" in

  # Mac OS
  Darwin)
    export OPENSSL_CONF='/System/Library/OpenSSL/openssl.cnf'
 	;;

  # Windows with Git Bash
  MINGW64*)
    export OPENSSL_CONF='C:/Program Files/Git/usr/ssl/openssl.cnf';
    export MSYS_NO_PATHCONV=1;
	;;
esac

#
# Define root certificate parameters
#
TRUSTSTORE_FILE_PREFIX='example.ca'
TRUSTSTORE_PASSWORD='Password1'
TRUSTSTORE_NAME="Self Signed CA for example.com"

#
# Define server certificate parameters
#
SERVER_KEYSTORE_FILE_PREFIX='example.server'
SERVER_KEYSTORE_PASSWORD='Password1'

#
# Create the root certificate public + private key protected by a passphrase
#
openssl genrsa -out $TRUSTSTORE_FILE_PREFIX.key 2048
echo 'Successfully created Root CA key'

openssl req \
    -x509 \
    -new \
    -nodes \
    -key $TRUSTSTORE_FILE_PREFIX.key \
    -out $TRUSTSTORE_FILE_PREFIX.pem \
    -subj "/CN=$TRUSTSTORE_NAME" \
    -reqexts v3_req \
    -extensions v3_ca \
    -sha256 \
    -days 3650
echo 'Successfully created Root CA'

providers=("provider1" "provider2" "provider3" "provider4")

for provider in ${providers[@]}
do
  #
  # Create the server SSL certificate and key, exported to a password protected P12 file
  #
  openssl genrsa -out $SERVER_KEYSTORE_FILE_PREFIX.$provider.key 2048

  openssl req \
      -new \
      -key $SERVER_KEYSTORE_FILE_PREFIX.$provider.key \
      -out $SERVER_KEYSTORE_FILE_PREFIX.$provider.csr \
      -subj "/CN=$provider.example.com"

  openssl x509 -req \
      -in $SERVER_KEYSTORE_FILE_PREFIX.$provider.csr \
      -CA $TRUSTSTORE_FILE_PREFIX.pem \
      -CAkey $TRUSTSTORE_FILE_PREFIX.key \
      -CAcreateserial \
      -out $SERVER_KEYSTORE_FILE_PREFIX.$provider.pem \
      -sha256 \
      -days 365 \
      -extfile extensions.cnf \
      -extensions server_ext

  openssl pkcs12 \
      -export -inkey $SERVER_KEYSTORE_FILE_PREFIX.$provider.key \
      -in $SERVER_KEYSTORE_FILE_PREFIX.$provider.pem \
      -name $provider.example.com \
      -out $SERVER_KEYSTORE_FILE_PREFIX.$provider.p12 \
      -passout pass:$SERVER_KEYSTORE_PASSWORD

done

#
# Java trust stores work best when also password protected, so use a P12 file for the root also
#
openssl pkcs12 \
    -export -inkey $TRUSTSTORE_FILE_PREFIX.key \
    -in $TRUSTSTORE_FILE_PREFIX.pem \
    -name $TRUSTSTORE_FILE_PREFIX \
    -out $TRUSTSTORE_FILE_PREFIX.p12 \
    -passout pass:$TRUSTSTORE_PASSWORD

#
# Remove files we no longer need
#
rm example.server*.csr
rm example.ca.srl
echo '*** Successfully created all certificate files'
