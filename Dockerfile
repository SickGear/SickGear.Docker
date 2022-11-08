# Edge has latest builds for py3-cryptography, py3-lxml, py3-wheel

FROM alpine:edge
RUN \
#	debug output disable/enable(+/-)
#	set +eux \
\
	printf "-------------------------------------------\n-------------------------------------------\n" \
	&& echo "*** Alpine v$(cat /etc/alpine-release) ***" \
	&& echo "Repositories:" \
	&& cat /etc/apk/repositories \
	&& echo "-------------------------------------------" \
\
	&& echo "*** Install Packages ***" \
	&& apk update && apk upgrade \
# musl-dev   python3-dev
	&& apk add --quiet --update --no-progress --virtual=build-deps1 curl \
	&& apk add --quiet --update --no-progress --virtual=build-deps2 g++ \
	&& apk add --quiet --update --no-progress --virtual=build-deps3 make \
	&& apk add --quiet --update --no-progress --virtual=build-deps4 py3-pip \
	&& apk add --quiet --update --no-progress --virtual=build-deps5 py3-wheel \
	&& apk add --update --no-progress \
		ca-certificates   git   libxml2   libxslt   shadow   su-exec   tzdata \
		py3-cffi   py3-cryptography   py3-lxml \
#	&& python3 -m pip install --upgrade pip wheel \
	&& echo "-------------------------------------------" \
\
	&& echo "*** Clone the Gear ***" \
	&& su-exec nobody true \
	&& export SG=/opt/SickGear \
	&& mkdir -p ${SG} \
	&& git clone -b develop --depth 1 https://github.com/SickGear/SickGear ${SG} \
	&& addgroup -S group \
	&& adduser -S -G group -h /opt/SickGear user \
	&& echo "-------------------------------------------" \
\
	&& echo "*** Install Python Packages ***" \
	&& python3 -V \
	&& pip3 -V \
	&& export PIP_ROOT_USER_ACTION=ignore \
	&& cd ${SG} \
	&& pip3 install --no-cache-dir -r requirements.txt \
	&& pip3 install --no-cache-dir -r recommended.txt \
	&& pip3 uninstall -q -y pycparser pyparsing retrying wheel \
	&& unset PIP_ROOT_USER_ACTION \
	&& echo \
	&& pip3 list \
	&& echo "-------------------------------------------" \
\
	&& echo "*** Build Unrar ***" \
	&& mkdir -p /tmp/unrar \
	&& curl -sL "https://raw.githubusercontent.com/wiki/SickGear/SickGear/packages/www.rarlab.com/rar/unrarsrc-6.2.1.tar.gz" \
		| tar xz -C /tmp/unrar --strip-components=1 \
	&& cd /tmp/unrar \
	&& make LDFLAGS=-static -f makefile \
	&& make install -f makefile \
	&& unrar \
		| awk '/^UNRAR/ {print $0;exit}' \
	&& echo "-------------------------------------------" \
\
	&& echo "*** Cleanup ***" \
	&& apk del --quiet --purge --no-progress \
		build-deps5 build-deps4 build-deps3 build-deps2 build-deps1 \
	&& find / -type d -name "__pycache__" | xargs rm -rf \
	&& rm -rf /tmp/* /root/.cache /var/cache/apk/* \
	&& echo "-------------------------------------------"

LABEL org.opencontainers.image.source https://github.com/jackdandy/sickgear

COPY base/ /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["sickgear.py"]

EXPOSE 8081

ENV APP_DATA="/data" PATH=/opt/SickGear/:$PATH LANG=C.UTF-8 TZ=UTC

# support 3 defaults + 2 other mount points
VOLUME /data /tv /incoming /config /downloads
