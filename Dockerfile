FROM python:2.7-alpine
MAINTAINER Sami Haahtinen <ressu@ressukka.net>

# Download su-exec, git and SickGear.
RUN apk add shadow \
      --update-cache \
      --repository http://dl-3.alpinelinux.org/alpine/edge/community/ \
      --allow-untrusted && \
    apk add \
      ca-certificates \
      curl \
      gcc \
      git \
      gnupg \
      libxml2 \
      libxml2-dev \
      libxslt \
      libxslt-dev \
      musl-dev \
      shadow \
      tzdata \
      su-exec \
      && \
    mkdir /opt && \
    git clone -b develop http://github.com/SickGear/SickGear /opt/SickGear && \
    pip install --no-cache-dir lxml && \
    pip install --no-cache-dir -r /opt/SickGear/requirements.txt && \
    groupadd group && \
    useradd -M -g group -d /opt/SickGear user && \
    apk del \
      ca-certificates \
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
