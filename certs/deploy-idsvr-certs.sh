#!/bin/bash

#########################################################################
# A post deployment script for financial grade, to configure certificates
#########################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

provider_ports=(6750 6751 6752 5753)
providers=("provider1" "provider2" "provider3" "provider4")

RESTCONF_BASE_URL='https://localhost'
RESTCONF_BASE_PATH='/admin/api/restconf/data'
ADMIN_USER='admin'
ADMIN_PASSWORD='Password1'
IDENTITY_SERVER_TLS_NAME='Identity_Server_TLS'
PRIVATE_KEY_PASSWORD='Password1'


#
# Add CA to the main instance's trust store
#

RESTCONF_URL=$RESTCONF_BASE_URL:6749$RESTCONF_BASE_PATH

#
# Wait for the admin endpoint to become available
#
echo "Waiting for the Curity Identity Server..."
while [ "$(curl -k -s -o /dev/null -w ''%{http_code}'' -u "$ADMIN_USER:$ADMIN_PASSWORD" "$RESTCONF_URL?content=config")" != "200" ]; do
  sleep 2
done

#
# Add the SSL key and use the private key password to protect it in transit
#
IDENTITY_SERVER_TLS_DATA=$(openssl base64 -in ./example.ca.p12 | tr -d '\n')

echo "Add the CA certificate to truststore..."
HTTP_STATUS=$(curl -k -s \
-X POST "$RESTCONF_URL/base:facilities/crypto/add-ssl-server-truststore" \
-u "$ADMIN_USER:$ADMIN_PASSWORD" \
-H 'Content-Type: application/yang-data+json' \
-d "{\"id\":\"$IDENTITY_SERVER_TLS_NAME\",\"password\":\"$PRIVATE_KEY_PASSWORD\",\"keystore\":\"$IDENTITY_SERVER_TLS_DATA\"}" \
-o /dev/null -w '%{http_code}')
if [ "$HTTP_STATUS" != '200' ]; then
  echo "Problem encountered adding the CA to trust store: $HTTP_STATUS"
  exit 1
fi

#
# Set Certificates for the provider instances
#
echo "Setting SSL certificates for the provider instances..."
for i in ${!providers[@]}; do
  RESTCONF_URL=$RESTCONF_BASE_URL:${provider_ports[$i]}$RESTCONF_BASE_PATH
  #
  # Wait for the admin endpoint to become available
  #
  echo "Waiting for the Curity Identity Server..."
  while [ "$(curl -k -s -o /dev/null -w ''%{http_code}'' -u "$ADMIN_USER:$ADMIN_PASSWORD" "$RESTCONF_URL?content=config")" != "200" ]; do
    sleep 2
  done

  #
  # Add the SSL key and use the private key password to protect it in transit
  #
  IDENTITY_SERVER_TLS_DATA=$(openssl base64 -in ./example.server.${providers[$i]}.p12 | tr -d '\n')

  echo "Updating SSL certificate..."
  HTTP_STATUS=$(curl -k -s \
  -X POST "$RESTCONF_URL/base:facilities/crypto/add-ssl-server-keystore" \
  -u "$ADMIN_USER:$ADMIN_PASSWORD" \
  -H 'Content-Type: application/yang-data+json' \
  -d "{\"id\":\"$IDENTITY_SERVER_TLS_NAME\",\"password\":\"$PRIVATE_KEY_PASSWORD\",\"keystore\":\"$IDENTITY_SERVER_TLS_DATA\"}" \
  -o /dev/null -w '%{http_code}')
  if [ "$HTTP_STATUS" != '200' ]; then
    echo "Problem encountered updating the runtime SSL certificate: $HTTP_STATUS"
    exit 1
  fi

  #
  # Set the SSL key as active for the runtime service role
  #
  HTTP_STATUS=$(curl -k -s \
  -X PATCH "$RESTCONF_URL/base:environments/base:environment/base:services/base:service-role=default" \
  -u "$ADMIN_USER:$ADMIN_PASSWORD" \
  -H 'Content-Type: application/yang-data+json' \
  -d "{\"base:service-role\": [{\"ssl-server-keystore\":\"$IDENTITY_SERVER_TLS_NAME\"}]}" \
  -o /dev/null -w '%{http_code}')
  if [ "$HTTP_STATUS" != '204' ]; then
    echo "Problem encountered updating the runtime SSL certificate: $HTTP_STATUS"
    exit 1
  fi

done
