FROM alpine:3.14.2

RUN \
# debug output disable/enable(+/-)
 set +eux && \
\
 echo "*** Install Packages ***" && \
 apk update && apk upgrade && \
 apk add --update --no-progress --virtual=build-deps \
  gcc   musl-dev   python3-dev   py3-pip   py3-wheel && \
 apk add --update --no-progress \
  ca-certificates   git   libxml2   libxslt   tzdata   shadow   su-exec   unrar \
  py3-cffi   py3-cheetah   py3-cryptography   py3-lxml   py3-regex && \
\
 echo "*** Install Python Packages ***" && \
 python3 -V && \
 pip3 -V && \
 pip3 install --no-cache-dir python-Levenshtein && \
 pip3 uninstall -q -y asn1crypto CacheControl certifi \
  chardet colorama contextlib2 html5lib idna lockfile msgpack  \
  ordered-set progress pyparsing requests retrying urllib3 webencodings && \
 find / -iname __pycache__ -exec rm -rf {} \; 2>/dev/null || true && \
 pip3 list && \
\
 echo "*** Install SG ***" && \
 su-exec nobody true && \
 mkdir -p /opt && \
 git clone -b develop --depth 1 https://github.com/SickGear/SickGear /opt/SickGear && \
 addgroup -S group && \
 adduser -S -G group -h /opt/SickGear user && \
\
# clean up
 apk del --quiet --purge --no-progress build-deps && \
 rm -rf /var/cache/apk/* 
 
LABEL org.opencontainers.image.source https://github.com/jackdandy/sickgear

COPY template /template
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["sickgear.py"]

EXPOSE 8081

ENV APP_DATA="/data" PATH=/opt/SickGear:$PATH LANG=C.UTF-8 TZ=UTC

# support default + other mount points
VOLUME /data /tv /incoming /config /downloads
