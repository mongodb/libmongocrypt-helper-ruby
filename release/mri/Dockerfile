FROM debian:10

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt-get -y install ruby-bundler

WORKDIR /app

COPY . .
