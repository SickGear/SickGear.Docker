#!/bin/sh
set -e

# If called with default arguments,
# invoke SickGear with datadir and set up the environment
if [ 'sickgear.py' = "$1" ]; then
  APP_UID="${APP_UID:=${PUID:=1000}}"
  APP_GID="${APP_GID:=${PGID:=1000}}"
  APP_UIDGID="${APP_UID}:${APP_GID}"
  export SG_OVER && SG_OVER=1

  # map user sickgear to APP_UID and APP_GID, busybox has no usermod
  sed -i -E "s/^sickgear:x:[0-9]+:[0-9]+:/sickgear:x:${APP_UID}:${APP_GID}:/" /etc/passwd
  sed -i -E "s/^sickgear:x:[0-9]+:/sickgear:x:${APP_GID}:/" /etc/group
  # su-exec keeps the root HOME, set the sickgear home for pip --user installs
  export HOME=/opt/SickGear

  if [ ! -f "${APP_DATA}/config.ini" ] && [ -f "/config/config.ini" ]; then
    APP_DATA="/config"
  fi

  cat > "${APP_DATA}/_DOCKER.txt" <<EOT
+--------------------------------------+
||      Official SickGear Docker      ||
||        Tracks branch:main        ||
+--------------------------------------+
Find third-party application helpers and
config files at; ${APP_DATA}/autoProcessTV/

SABnzbd sample config file;
$ cp ./autoProcessTV.cfg.sample ./autoProcessTV.cfg
Deluge or Transmission sample config file;
$ cp ./onTxComplete.sample.cfg ./onTxComplete.cfg

On download completed helpers;
+- NZBGet, ./SickGear-NG/SickGear-NG.py
+- SABnzbd, ./sabToSickGear.py
+- Torrent (*nix), ./onTxComplete.sh
+- Torrent (Win), ./onTxComplete.bat
+----------------------------------------+
file "${APP_DATA}/_DOCKER.txt"     
+----------------------------------------+
EOT
  cat "${APP_DATA}/_DOCKER.txt"

  if [ $(stat -c "%u:%g" ${APP_DATA}) != "${APP_UIDGID}" ]; then
    chown -R ${APP_UIDGID} "${APP_DATA}"
  fi
  chown ${APP_UIDGID} "${APP_DATA}/_DOCKER.txt"

  if [ ! -f "${APP_DATA}/config.ini" ]; then
    su-exec ${APP_UIDGID} cp /template/config.ini "${APP_DATA}/"
    if [ ! -f "${APP_DATA}/config.ini" ]; then
      echo "Make sure to mount <host/path>:${APP_DATA} with correct perms"
      exit
    fi
  fi

  if [ -f "${APP_DATA}/config.ini" ]; then
    sed -i -E 's/dev(")?$/main\1/' "${APP_DATA}/config.ini"
    sed -i -E 's/cur_commit_hash = "[^"]*"$/cur_commit_hash = "docker (official)"/' "${APP_DATA}/config.ini"
    sed -i -E 's/cur_commit_branch = "[^"]*"$/cur_commit_branch = "main"/' "${APP_DATA}/config.ini"
  fi

  cd /opt/SickGear

  su-exec ${APP_UIDGID} cp -Rf ./autoProcessTV "${APP_DATA}"
  chown -R ${APP_UIDGID} "${APP_DATA}/autoProcessTV"

  exec su-exec ${APP_UIDGID} python3 "$@" --datadir="${APP_DATA}"
else
  exec "$@"
fi

