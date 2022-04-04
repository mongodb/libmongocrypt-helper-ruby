#!/bin/sh

set -e

docker build -t libmongocrypt-so .

mkdir -p lib/so

docker run -t libmongocrypt-so cat /libmongocrypt.so > lib/so/libmongocrypt.so
