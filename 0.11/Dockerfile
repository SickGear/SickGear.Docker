FROM python:2.7-alpine

# grab gosu for easy step-down from root
RUN apk add --update ca-certificates curl gnupg && \
    gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    ARCH=`uname -m`; if [ $ARCH == "x86_64" ]; then export ARCH="amd64"; else export ARCH="i386"; fi && \
    curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$ARCH" && \
    curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$ARCH.asc" && \
    gpg --verify /usr/local/bin/gosu.asc && \
    rm /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu && \
    apk del ca-certificates curl gnupg && \
    rm -rf /var/cache/apk/*

ENV SICKGEAR_VERSION 0.11.5

RUN apk add --update \
      ca-certificates \
      curl \
      gcc \
      libxml2 \
      libxml2-dev \
      libxslt \
      libxslt-dev \
      musl-dev \
      tzdata \
      && \
    mkdir /opt && \
    curl -SL "https://github.com/SickGear/SickGear/archive/release_${SICKGEAR_VERSION}.tar.gz" | \
      tar xz -C /opt && \
    mv /opt/SickGear-release_${SICKGEAR_VERSION} /opt/SickGear && \
    pip install --no-cache-dir lxml && \
    pip install --no-cache-dir -r /opt/SickGear/requirements.txt && \
    apk del \
      ca-certificates \
      curl \
      gcc \
      libxml2-dev \
      libxslt-dev \
      musl-dev \
      && \
    rm -rf /var/cache/apk/*

WORKDIR /opt/SickGear

ENV APP_DATA="/data" PATH=/opt/SickGear:$PATH

EXPOSE 8081
VOLUME /data /tv /incoming

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["SickBeard.py"]
