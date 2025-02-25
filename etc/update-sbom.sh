#!/usr/bin/env bash

SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})
ROOT_DIR=$(realpath "${SCRIPT_DIR}/../")
VERSION_FILE="${ROOT_DIR}/lib/libmongocrypt_helper/version.rb"
PURLS_FILE="${ROOT_DIR}/purls.txt"

# Extract libmongocrypt version from version file. The sequence "'\''" in sed matches a single quote
LIBMONGOCRYPT_VERSION=$(grep -e "LIBMONGOCRYPT_VERSION = " ${VERSION_FILE} | sed -n -e 's/^.*LIBMONGOCRYPT_VERSION = '\''\(.*\)'\''$/\1/p')

# Generate purls file from stored versions
echo "pkg:github/mongodb/libmongocrypt@${LIBMONGOCRYPT_VERSION}" > $PURLS_FILE

# Use silkbomb to update the sbom.json file
docker run --platform="linux/amd64" -it --rm -v ${ROOT_DIR}:/pwd \
  artifactory.corp.mongodb.com/release-tools-container-registry-public-local/silkbomb:2.0 \
  update --sbom-in /pwd/sbom.json --purls /pwd/purls.txt --sbom-out /pwd/sbom.json

rm $PURLS_FILE
