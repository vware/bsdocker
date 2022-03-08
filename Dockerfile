# Buildstage
FROM ghcr.io/linuxserver/baseimage-alpine:3.15 as buildstage
# set BRICKSYNC version
ARG BRICKSYNC_RELEASE
RUN \
  echo "**** install build packages ****" && \
  apk add \
    gcc \
    git \
    libc-dev \
    make \
    openssl-dev && \
  echo "**** build bricksync ****" && \
  mkdir -p /app/bricksync && \
  git clone https://github.com/vware/bricksync.git bricksync && \
  cd bricksync/ && \
  git checkout ${BRICKSYNC_RELEASE} && \
  make && \
  make DESTDIR=/app/bricksync install
# Runtime Stage
FROM ghcr.io/linuxserver/baseimage-alpine:3.15
# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="vware"
# add files from buildstage
RUN \
  echo "**** import package ****" && \
  apk add --no-cache \
    openssl
COPY --from=buildstage /app/bricksync /app/bricksync
COPY root/ /
# ports and volumes
VOLUME /data
