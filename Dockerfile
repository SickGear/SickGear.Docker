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
		py3-cffi   py3-cryptography   py3-lxml \
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
		./.gitignore ./_cleaner.py ./CHANGES.md ./HACKS.txt \
		./recommended.txt ./recommended-remove.txt  ./readme.md \
		./requirements.txt ./SickBeard.py ./.travis.yml ./tox.ini \
		./lib/bs4_py2 ./lib/diskcache_py2 ./lib/feedparser_py2 \
		./lib/hachoir_py2 ./lib/js2py ./lib/pyjsparser \
		./lib/pytz/tests ./lib/rarfile_py2 ./lib/rarfile/UnRAR.exe \
		./lib/soupsieve_py2 ./lib/tornado_py2 \
	&& export TMP=/tmp/sgtemp/ \
	&& mkdir -p ${TMP} \
	&& find ./lib/pytz/zoneinfo/ -maxdepth 1 -type f -exec cp -p '{}' ${TMP} \; \
	&& cp -rp ./lib/pytz/zoneinfo/Etc ${TMP} \
	&& rm -rf ./lib/pytz/zoneinfo/* \
	&& cp -rp ${TMP}* ./lib/pytz/zoneinfo/ \
	&& export TMP=/tmp/apprise/ \
	&& mkdir -p ${TMP} \
	&& cp -rp \
		./lib/apprise/plugins/__init__.py \
		./lib/apprise/plugins/*Base.py \
		./lib/apprise/plugins/*Email.py \
		./lib/apprise/plugins/*Growl ${TMP} \
	&& rm -rf ./lib/apprise/plugins/* \
	&& cp -rp ${TMP}* ./lib/apprise/plugins/ \
	&& unset TMP \
	&& echo "-------------------------------------------" \
\
	&& echo "*** Install Python Packages ***" \
	&& python3 -V \
	&& pip3 -V \
	&& export PIP_ROOT_USER_ACTION=ignore \
	&& pip3 install --no-cache-dir --quiet CT3 \
	&& pip3 install --no-cache-dir --quiet Levenshtein \
	&& pip3 install --no-cache-dir --quiet regex \
	&& pip3 uninstall -q -y contextlib2 pycparser pyparsing retrying wheel \
	&& unset PIP_ROOT_USER_ACTION \
	&& find / -iname "*.pyi" -exec rm -f '{}' \; \
	&& PYV=$(python3 -c 'import sys; print(".".join([str(x) for x in sys.version_info[0:2]]))') \
	&& rm -rf /usr/lib/python$PYV/site-packages/Cheetah/Tests /usr/lib/python$PYV/ensurepip \
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
