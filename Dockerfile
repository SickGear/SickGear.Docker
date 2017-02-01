FROM python:2.7
MAINTAINER Sami Haahtinen <ressu@ressukka.net>

ENV GOSU_VERSION 1.9
ENV SICKGEAR_VERSION 0.12.5

# Download gosu and SickGear.
RUN set -x \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget curl libxml2-dev libxslt-dev \
    && rm -rf /var/lib/apt/lists/* \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
      && \
    curl -SL "https://github.com/SickGear/SickGear/archive/release_${SICKGEAR_VERSION}.tar.gz" | \
      tar xz -C /opt && \
    mv /opt/SickGear-release_${SICKGEAR_VERSION} /opt/SickGear && \
    pip install --no-cache-dir lxml && \
    pip install --no-cache-dir -r /opt/SickGear/requirements.txt \
    && rm -rf /var/lib/apt/lists/*



ENV APP_DATA="/data" PATH=/opt/SickGear:$PATH

EXPOSE 8081
VOLUME /data /tv /incoming

COPY template /template
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["SickBeard.py"]
