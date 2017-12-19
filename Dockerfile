FROM python:2.7-alpine
MAINTAINER Sami Haahtinen <ressu@ressukka.net>

# Download SickGear with git. Keep git to enable dev work and testing.
RUN apk add --update \
      ca-certificates \
      curl \
      gcc \
      gnupg \
      libxml2 \
      libxml2-dev \
      libxslt \
      libxslt-dev \
      musl-dev \
      tzdata \
      su-exec \
      git \
      && \
    mkdir /opt && \
    cd /opt && \
    git clone --depth 1 -b develop https://github.com/SickGear/SickGear.git && \
    pip install --no-cache-dir lxml && \
    pip install --no-cache-dir -r /opt/SickGear/requirements.txt && \
    apk del \
      curl \
      gcc \
      gnupg \
      libxml2-dev \
      libxslt-dev \
      musl-dev \
      && \
    rm -rf /var/cache/apk/*

ENV APP_DATA="/data" PATH=/opt/SickGear:$PATH

EXPOSE 8081
VOLUME /data /tv /incoming

COPY template /template
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["SickBeard.py"]
