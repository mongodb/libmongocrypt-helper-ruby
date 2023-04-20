FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt-get -y install ruby-bundler ruby-dev build-essential cmake git

WORKDIR /app

COPY . .
