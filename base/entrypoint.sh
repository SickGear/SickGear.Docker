#!/bin/sh
set -e

# If called with default arguments,
# invoke SickGear with datadir and set up the environment
if [ 'sickgear.py' = "$1" ]; then
  APP_UID="${APP_UID:=${PUID:=0}}"
  APP_GID="${APP_GID:=${PGID:=0}}"
  APP_UIDGID="${APP_UID}:${APP_GID}"
  export SG_OVER && SG_OVER=1

  # For git, user is needed with gid and uid
  if [ 0 -ne ${APP_GID:=0} ]; then
    groupmod -o -g ${APP_GID} group
  fi
  if [ 0 -ne ${APP_UID:=0} ]; then
    usermod -o -u ${APP_UID} -g ${APP_GID} user
  fi

  if [ ! -f "${APP_DATA}/config.ini" ] && [ -f "/config/config.ini" ]; then
    APP_DATA="/config"
  fi

  cat > "${APP_DATA}/_DOCKER.txt" <<EOT
+--------------------------------------+
||      Official SickGear Docker      ||
||         Tracks branch:dev          ||
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
+--------------------------------------+
file "${APP_DATA}/_DOCKER.txt"     
+--------------------------------------+
EOT
  cat "${APP_DATA}/_DOCKER.txt"

  if [ ! -f "${APP_DATA}/config.ini" ]; then
    echo "Creating new ${APP_DATA}/config.ini"
    su-exec ${APP_UIDGID} cp /template/config.ini "${APP_DATA}/"
    if [ ! -f "${APP_DATA}/config.ini" ]; then
      echo "Make sure to mount <host/path>:${APP_DATA} with correct perms"
      exit
    fi
  fi

  # For development branch, chown the SickGear installation
  chown -R ${APP_UIDGID} "${APP_DATA}"
  chown -R ${APP_UIDGID} /opt/SickGear

  cd /opt/SickGear

  # Update the installation to latest git revision
  su-exec ${APP_UIDGID} git pull

  if [ -f "${APP_DATA}/config.ini" ]; then
    su-exec ${APP_UIDGID} sed -i -E 's/main(")?$/dev\1/' "${APP_DATA}/config.ini"
    su-exec ${APP_UIDGID} sed -i -E 's/cur_commit_hash = .*$/cur_commit_hash = '$(su-exec ${APP_UIDGID} git rev-parse HEAD)'/' "${APP_DATA}/config.ini"
    su-exec ${APP_UIDGID} sed -i -E 's/cur_commit_branch = .*$/cur_commit_branch = dev/' "${APP_DATA}/config.ini"
  fi
 
  su-exec ${APP_UIDGID} cp -Rf ./autoProcessTV "${APP_DATA}"
  chown -R ${APP_UIDGID} "${APP_DATA}/autoProcessTV"

  exec su-exec ${APP_UIDGID} python3 "$@" --datadir="${APP_DATA}" &

  while true; do
    sleep 5
  done
else
  exec "$@"
fi
