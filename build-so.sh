#!/bin/sh

set -e

docker build -t libmongocrypt-so .

mkdir -p so

docker run libmongocrypt-so tar cf - -C / libmongocrypt.so | tar xf - -C so

./check-so-version
