#!/bin/bash

#######################################################
# A script to deploy Dynamic Authenticator resources. #
#######################################################

export CONFIG_ENCRYPTION_KEY="02b891b3ec501cece86de216a6f6a15f585dddcbd56fe21b410233d78dfaa79e"

usage()
{
  echo "A script to deploy Dynamic Authenticator Demo resources"
  echo ""
  echo "Usage: deploy.sh [ -a | --rebuild-api ] [ -c | --regenerate-certs ]"
  exit 2
}

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# First check prerequisites
#
if [ ! -f './idsvr/license.json' ]; then
  echo "Please provide a license.json file in the idsvr folder in order to deploy the system."
  exit 1
fi

#
# Parse the script options
#
REBUILD_API=0
REGENERATE_CERTS=0

while getopts "ca-:" option; do
  case $option in
  c) REGENERATE_CERTS=1
    ;;
  a) REBUILD_API=1
    ;;
  -)
    case $OPTARG in
    regenerate-certs) REGENERATE_CERTS=1
      ;;
    rebuild-api) REBUILD_API=1
      ;;
    *) usage
      ;;
    esac
    ;;
  *) usage
    ;;
  esac
done

#
# Create certificates if needed
#

if [ ! -f './certs/example.ca.p12' ] || [ $REGENERATE_CERTS == 1 ]; then
  echo "Creating certificates for idsvr instances."
  ./certs/create-certs.sh

  if [ $? -ne 0 ]; then
     echo "Problem encountered when creating certificates."
     exit 1
  fi
fi

#
# Spin up all containers, using the Docker Compose file.
#
echo "Deploying resources."
docker compose --project-name dynamic-auth down

if [ $REBUILD_API == 1 ]; then
  docker compose --project-name dynamic-auth up --detach --build
else
  docker compose --project-name dynamic-auth up --detach
fi

if [ $? -ne 0 ]; then
  echo "Problem encountered starting Docker components"
  exit 1
fi

echo "Uploading server certificates"

./certs/deploy-idsvr-certs.sh

if [ $? -ne 0 ]; then
  echo "Problem encountered when uploading certificates"
  exit 1
fi
