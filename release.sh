#!/bin/sh

set -e

NAME=libmongocrypt-helper
RELEASE_NAME=libmongocrypt-helper-release
VERSION_REQUIRE=libmongocrypt_helper/version
VERSION_CONSTANT_NAME=LibmongocryptHelper::VERSION

if ! test -f gem-private_key.pem; then
  echo "gem-private_key.pem missing - cannot release" 1>&2
  exit 1
fi

VERSION=`ruby -Ilib -r$VERSION_REQUIRE -e "puts $VERSION_CONSTANT_NAME"`

echo "Releasing $NAME $VERSION"
echo

./release/mri/build.sh
cp pkg/$NAME-$VERSION.gem .

echo
echo Built: $NAME-$VERSION.gem
echo

git tag -a v$VERSION -m "Tagging release: $VERSION"
git push origin v$VERSION

gem push $NAME-$VERSION.gem
