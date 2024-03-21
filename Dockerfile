FROM bitnami/minideb:latest

## always download the most recent version from gunthy.org
ARG INSTALL_URL="https://gunthy.org/downloads/gunthy_linux.zip"
ARG DEBIAN_FRONTEND=noninteractive

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF org.label-schema.vcs-url="https://github.com/robbatt/docker-gunbot"

## Setup Enviroment
ENV TZ=Europe/Berlin \
TERM=xterm-256color \
FORCE_COLOR=true \
NPM_CONFIG_COLOR=always \
MOCHA_COLORS=true \
INSTALL_URL=${INSTALL_URL}

## Setup pre-requisites
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get -y update && \
 apt-get install -y apt-utils

## Install additional libraries and upgrade
RUN apt-get -y upgrade && \
 apt-get install -y unzip curl fontconfig fonts-dejavu-extra ca-certificates && \
 apt-get clean -y && \
 apt-get autoclean -y && \
 apt-get autoremove -y

RUN update-ca-certificates --fresh

RUN fc-cache -fv

## Install Gunbot
WORKDIR /tmp
RUN curl -Lo /tmp/lin.zip ${INSTALL_URL}

RUN unzip -q lin.zip \
 && rm lin.zip \
 && rm -rf __MACOSX \
 && rm config.js \
 && rm autoconfig.json \
 && rm UTAconfig.json \
 && mkdir -p /gunbot \
 && mv * /gunbot \
 && chmod +x /gunbot/gunthy-linux

WORKDIR /gunbot

EXPOSE 5000
VOLUME [ \
	"/gunbot/backups", \
	"/gunbot/logs", \
	"/gunbot/json", \
	"/gunbot/customStrategies" \
]

CMD /gunbot/gunthy-linux
