FROM debian:9

ENV DEBIAN_FRONTEND=noninteractive

RUN printf "deb http://httpredir.debian.org/debian stretch-backports main\ndeb-src \
          http://httpredir.debian.org/debian stretch-backports main\n\
          deb http://httpredir.debian.org/debian stretch-backports-sloppy main\n\
          deb-src http://httpredir.debian.org/debian stretch-backports-sloppy main" > /etc/apt/sources.list.d/backports.list

RUN apt-get update && apt-get install -y -t stretch-backports-sloppy libarchive13

RUN apt-get install -y -t stretch-backports cmake

RUN apt-get -y install curl git python3 gcc g++

RUN git clone https://github.com/mongodb/mongo-c-driver && \
  cd mongo-c-driver && \
  git checkout 1.21.1 && \
  mkdir xbuild && \
  cd xbuild && \
  cmake -DENABLE_MONGOC=OFF -DCMAKE_INSTALL_PREFIX="/opt/bson" ../ && \
  make -j`cat /proc/cpuinfo |grep ^processor |wc -l` install

RUN curl -fL https://codeload.github.com/mongodb/libmongocrypt/tar.gz/refs/tags/1.5.0-alpha1 |tar xfz -

# libmongocrypt does not build from release packages (on GH releases page) -
# it demands its git repo to build.
# Options to build without native crypto are not documented.
RUN git clone https://github.com/mongodb/libmongocrypt && \
  cd libmongocrypt && \
  git checkout 1.5.0-alpha1 && \
  mkdir xbuild && \
  cd xbuild && \
  cmake -DCMAKE_PREFIX_PATH="/opt/bson" \
    -DCMAKE_PREFIX_PATH=/opt/bson \
    -DDISABLE_NATIVE_CRYPTO=1 -DMONGOCRYPT_CRYPTO=none -DMONGOCRYPT_ENABLE_CRYPTO=0 \
    .. && \
  make && \
  ldd libmongocrypt.so && \
  cp libmongocrypt.so /
