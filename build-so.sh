#!/bin/sh

set -e

docker build -t libmongocrypt-so .

mkdir -p so

docker run -t libmongocrypt-so cat /libmongocrypt.so > so/libmongocrypt.so
