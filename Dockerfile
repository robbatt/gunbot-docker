FROM bitnami/minideb:latest

## this is only the executable from the repo, assuming we have a working setup with mounted volumes (gunthy_linux exe only)
ARG GUNBOT_VERSION="30.6.7"
ARG INSTALL_URL_VERSIONED="https://gunthy.org/downloads/repo/gunthy-linux_${GUNBOT_VERSION}.zip"

## to download the most recent version from gunthy.org (full package)
ARG INSTALL_URL_LATEST="https://gunthy.org/downloads/gunthy_linux.zip"


ARG INSTALL_URL_FULL=${INSTALL_URL_LATEST}
ARG INSTALL_URL_VERSION=${INSTALL_URL_VERSIONED}
ARG DEBIAN_FRONTEND=noninteractive
ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF org.label-schema.vcs-url="https://github.com/robbatt/docker-gunbot"

## Setup Enviroment
ENV TZ=Europe/Berlin \
TERM=xterm-256color \
FORCE_COLOR=true \
NPM_CONFIG_COLOR=always \
MOCHA_COLORS=true \
INSTALL_URL_FULL=${INSTALL_URL_FULL} \
INSTALL_URL_VERISONED=${INSTALL_URL_VERSIONED}

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
RUN curl -Lo /tmp/lin.zip ${INSTALL_URL_FULL}

RUN unzip -q lin.zip \
 && rm lin.zip \
 && rm config.js \
 && rm config-js-example.txt \
 && rm autoconfig.json \
 && rm UTAconfig.json \
# && rm gunthy-linux \
 && chmod +x gunthy-linux \
 && mkdir -p /gunbot \
 && mv * /gunbot
# && chmod +x /gunbot/gunthy-linux # removed because buggy, replaced with following versioned exe

#RUN curl -Lo /tmp/lin_versioned.zip ${INSTALL_URL_VERISONED}
#RUN unzip -q lin_versioned.zip \
# && rm lin_versioned.zip \
# && mv gunthy-linux /gunbot/ \
# && chmod +x /gunbot/gunthy-linux

WORKDIR /gunbot

EXPOSE 5000
VOLUME [ \
	"/gunbot/backups", \
	"/gunbot/logs", \
	"/gunbot/json", \
	"/gunbot/customStrategies" \
]

CMD ["gunthy-linux"]
