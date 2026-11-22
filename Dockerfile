FROM alpine:edge
RUN \
	printf "-------------------------------------------\n-------------------------------------------\n" \
	&& echo "*** Alpine v$(cat /etc/alpine-release) ***" \
	&& echo "Repositories:" \
	&& cat /etc/apk/repositories \
	&& echo "-------------------------------------------" \
\
	&& echo "*** Install Packages ***" \
	&& apk add --quiet --update --no-progress --virtual=build-deps1 curl \
	&& apk add --quiet --update --no-progress --virtual=build-deps2 g++ \
	&& apk add --quiet --update --no-progress --virtual=build-deps3 make \
	&& apk add --quiet --update --no-progress --virtual=build-deps4 cmake \
	&& apk add --quiet --update --no-progress --virtual=build-deps5 py3-pip \
	&& apk add --quiet --update --no-progress --virtual=build-deps6 py3-wheel \
	&& apk add --quiet --update --no-progress --virtual=build-deps7 python3-dev \
	&& apk add --update --no-progress \
		ca-certificates   libxml2   libxslt   su-exec   tzdata \
		py3-brotli   py3-cffi   py3-cryptography   py3-lxml   py3-orjson   py3-rapidfuzz \
	&& echo "-------------------------------------------" \
\
	&& echo "*** Fetching latest release tag ***" \
	&& TAG_NAME=$(curl -sL "https://api.github.com/repos/sickgear/sickgear/releases/latest" \
		| awk '/tag_name/{print $4;exit}' FS='[""]') \
	&& echo "*** Install Gear tagged ${TAG_NAME} ***" \
	&& export SG=/opt/SickGear \
	&& mkdir -p ${SG} \
	&& curl -sL "https://github.com/SickGear/SickGear/archive/${TAG_NAME}.tar.gz" \
		| tar xz -C ${SG} --strip-components=1 \
	&& cd ${SG} \
	&& rm -rf \
		./.github ./init-scripts ./snap ./tests ./.codeclimate.yml \
		./.gitignore ./.gitlab-ci.yml ./_cleaner.py ./CHANGES.md \
		./CODE_OF_CONDUCT.md ./CONTRIBUTING.md ./HACKS.txt \
		./recommended.txt ./recommended-remove.txt ./readme.md \
		./requirements.txt ./SickBeard.py ./tox.ini \
		./lib/fuzzywuzzy ./lib/js2py ./lib/pyjsparser ./lib/rarfile/UnRAR.exe \
	&& export TMP=/tmp/apprise/ \
	&& mkdir -p ${TMP} \
	&& cp -rp \
		./lib/apprise/plugins/__init__.py \
		./lib/apprise/plugins/base.py \
		./lib/apprise/plugins/email \
		./lib/apprise/plugins/gntp \
		./lib/apprise/plugins/growl.py ${TMP} \
	&& rm -rf ./lib/apprise/plugins/* \
	&& cp -rp ${TMP}* ./lib/apprise/plugins/ \
	&& unset TMP \
	&& addgroup -S -g 1000 sickgear \
	&& adduser -S -D -u 1000 -G sickgear -h ${SG} -s /sbin/nologin sickgear \
	&& echo "-------------------------------------------" \
\
	&& echo "*** Install Python Packages ***" \
	&& python3 -V \
	&& pip3 -V \
	&& export PIP_ROOT_USER_ACTION=ignore \
	&& export PIP_BREAK_SYSTEM_PACKAGES=1 \
	&& pip3 install --no-cache-dir --quiet CT3 \
	&& pip3 install --no-cache-dir --quiet regex \
	&& pip3 uninstall -q -y pycparser pyparsing wheel \
	&& unset PIP_ROOT_USER_ACTION PIP_BREAK_SYSTEM_PACKAGES \
	&& find / -iname "*.pyi" -exec rm -f '{}' \; \
	&& PYV=$(python3 -c 'import sys; print(".".join([str(x) for x in sys.version_info[0:2]]))') \
	&& rm -rf /usr/lib/python$PYV/site-packages/Cheetah/Tests /usr/lib/python$PYV/ensurepip \
	&& echo \
	&& pip3 list \
	&& echo "-------------------------------------------" \
\
	&& echo "*** Build Unrar ***" \
	&& mkdir -p /tmp/unrar \
	&& curl -sL -o /tmp/unrarsrc.tar.gz "https://raw.githubusercontent.com/wiki/SickGear/SickGear/packages/www.rarlab.com/rar/unrarsrc-7.2.7.tar.gz" \
	&& echo "01d903a7dcf413cb2925696d7796e48e38d471f79bfe7ef3ad2aebf6c12dbefd  /tmp/unrarsrc.tar.gz" \
		| sha256sum -c - \
	&& tar xzf /tmp/unrarsrc.tar.gz -C /tmp/unrar --strip-components=1 \
	&& cd /tmp/unrar \
	&& make LDFLAGS=-static -f makefile \
	&& make install -f makefile \
	&& unrar \
		| awk '/^UNRAR/ {print $0;exit}' \
	&& echo "-------------------------------------------" \
\
	&& echo "*** Cleanup ***" \
	&& apk del --quiet --purge --no-progress \
		build-deps7 build-deps6 build-deps5 build-deps4 build-deps3 build-deps2 build-deps1 \
	&& find / -type d -name "__pycache__" | xargs rm -rf \
	&& rm -rf /tmp/* /root/.cache /var/cache/apk/* \
	&& echo "-------------------------------------------"

COPY base/ /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["sickgear.py"]

EXPOSE 8081

ENV APP_DATA="/data" PATH=/opt/SickGear/:$PATH LANG=C.UTF-8 TZ=UTC

# support 3 defaults + 2 other mount points
VOLUME /data /tv /incoming /config /downloads
