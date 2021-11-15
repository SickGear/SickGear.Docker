FROM alpine:3.14.3

RUN \
 echo "*** Install Packages ***" && \
 apk add --update --no-progress  --virtual=build-deps \
  curl   gcc   musl-dev   python3-dev   py3-pip   py3-wheel && \
 apk add --update --no-progress \
  ca-certificates   libxml2   libxslt   su-exec   tzdata   unrar \
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
 echo "*** Install SickGear ***" && \
 mkdir -p /opt && \
 TAG_NAME=$(curl -s https://api.github.com/repos/SickGear/SickGear/releases | \
   python3 -c "import sys, json; print(json.load(sys.stdin)[0]['tag_name'])") && \
\
 echo "*** Fetching from tag ${TAG_NAME} ***" && \
 curl -SL "https://github.com/SickGear/SickGear/archive/${TAG_NAME}.tar.gz" | \
  tar xz -C /opt && \
 mv /opt/SickGear-${TAG_NAME} /opt/SickGear && \
 cd /opt/SickGear && \
 rm -rf ./.codeclimate.yml ./.github ./.gitignore \
   ./tests ./_cleaner.py ./HACKS.txt \
   ./recommended.txt ./requirements.txt \
   ./SickBeard.py ./snap ./.travis.yml ./tox.ini && \
\
# clean up
 apk del --quiet --purge --no-progress build-deps && \
 rm -rf /var/cache/apk/*

COPY template /template
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["sickgear.py"]

EXPOSE 8081

ENV APP_DATA="/data" PATH=/opt/SickGear:$PATH LANG=C.UTF-8 TZ=UTC

VOLUME /data /tv /incoming
# support other mount points
VOLUME /config /downloads
