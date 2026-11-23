# UnRAR is built in its own stage, the build cache then reuses it until the source or the base image changes
FROM alpine:3.24 AS unrar
RUN \
	echo "*** Build Unrar ***" \
	&& apk add --quiet --update --no-progress curl g++ make \
	&& mkdir -p /tmp/unrar \
	&& curl -sL -o /tmp/unrarsrc.tar.gz "https://raw.githubusercontent.com/wiki/SickGear/SickGear/packages/www.rarlab.com/rar/unrarsrc-7.2.7.tar.gz" \
	&& echo "01d903a7dcf413cb2925696d7796e48e38d471f79bfe7ef3ad2aebf6c12dbefd  /tmp/unrarsrc.tar.gz" \
		| sha256sum -c - \
	&& tar xzf /tmp/unrarsrc.tar.gz -C /tmp/unrar --strip-components=1 \
	&& cd /tmp/unrar \
	&& make LDFLAGS=-static -f makefile \
	&& make install -f makefile \
	&& unrar \
		| awk '/^UNRAR/ {print $0;exit}'

FROM alpine:3.24
COPY --from=unrar /usr/bin/unrar /usr/bin/unrar
# allow pip to install into Alpine system Python, at build and for in-app installs by SickGear piper
ENV PIP_BREAK_SYSTEM_PACKAGES=1
# a new value for each CI build, so the dev clone and packages below are fetched again, not taken from the build cache
ARG BUILD_ID=local
RUN \
#	debug output disable/enable(+/-)
#	set +eux \
\
	printf "-------------------------------------------\n-------------------------------------------\n" \
	&& echo "*** Build ${BUILD_ID} ***" \
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
	&& apk add --quiet --update --no-progress --virtual=build-deps5 py3-wheel \
	&& apk add --update --no-progress \
		ca-certificates   git   su-exec   tzdata \
		py3-brotli   py3-pip \
#	&& python3 -m pip install --upgrade pip wheel \
	&& echo "-------------------------------------------" \
\
	&& echo "*** Clone the Gear ***" \
	&& su-exec nobody true \
	&& export SG=/opt/SickGear \
	&& mkdir -p ${SG} \
	&& git clone -b dev --depth 1 https://github.com/SickGear/SickGear ${SG} \
	&& addgroup -S -g 1000 sickgear \
	&& adduser -S -D -u 1000 -G sickgear -h ${SG} -s /sbin/nologin sickgear \
	&& echo "-------------------------------------------" \
\
	&& echo "*** Install Python Packages ***" \
	&& python3 -V \
	&& pip3 -V \
	&& export PIP_ROOT_USER_ACTION=ignore \
	&& cd ${SG} \
	&& pip3 install --no-cache-dir -U -r requirements.txt \
	&& pip3 install --no-cache-dir -U -r recommended.txt \
# rtls lets niquests use Encrypted Client Hello, no wheel for arm/v6, ppc64le, s390x, so those skip it
	&& { pip3 install --no-cache-dir --quiet --only-binary=rtls rtls \
		|| echo "*** No rtls wheel for $(uname -m), skipped ***"; } \
	&& pip3 uninstall -q -y pycparser pyparsing retrying wheel \
	&& unset PIP_ROOT_USER_ACTION \
	&& rm -rf /usr/lib/python3*/ensurepip \
	&& echo \
	&& pip3 list \
	&& echo "-------------------------------------------" \
\
	&& unrar \
		| awk '/^UNRAR/ {print $0;exit}' \
	&& echo "-------------------------------------------" \
\
	&& echo "*** Cleanup ***" \
	&& apk del --quiet --purge --no-progress \
		build-deps5 build-deps2 build-deps1 \
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
