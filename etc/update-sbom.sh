#!/usr/bin/env bash

SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})
ROOT_DIR=$(realpath "${SCRIPT_DIR}/../")
VERSION_FILE="${ROOT_DIR}/lib/libmongocrypt_helper/version.rb"
PURLS_FILE="${ROOT_DIR}/purls.txt"

# Extract libmongocrypt version from version file. The sequence "'\''" in sed matches a single quote
LIBMONGOCRYPT_VERSION=$(grep -e "LIBMONGOCRYPT_VERSION = " ${VERSION_FILE} | sed -n -e 's/^.*LIBMONGOCRYPT_VERSION = '\''\(.*\)'\''$/\1/p')

# Generate purls file from stored versions
echo "pkg:github/mongodb/libmongocrypt@${LIBMONGOCRYPT_VERSION}" > $PURLS_FILE

# Log in to the DevProd Platforms ECR registry. Requires membership in the
# devprod-platforms-ecr-users Okta group and an AWS SSO profile — see
# https://docs.devprod.prod.corp.mongodb.com/devprod-platforms-ecr
profile="${DEVPROD_PLATFORMS_ECR_AWS_PROFILE:-ECRScopedAccess-901841024863}"
aws ecr get-login-password --region us-east-1 --profile "$profile" | docker login --username AWS --password-stdin 901841024863.dkr.ecr.us-east-1.amazonaws.com

# Use silkbomb to update the sbom.json file
docker run --platform="linux/amd64" -it --rm -v ${ROOT_DIR}:/pwd \
  901841024863.dkr.ecr.us-east-1.amazonaws.com/release-infrastructure/silkbomb:2.0 \
  update --sbom-in /pwd/sbom.json --purls /pwd/purls.txt --sbom-out /pwd/sbom.json

rm $PURLS_FILE
