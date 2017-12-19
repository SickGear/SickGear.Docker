#!/bin/sh
set -e

# If we are called with default arguments, invoke SickGear with datadir and
# setup the environment
if [ "$1" = 'SickBeard.py' ]; then
  APP_DATA_UIDGID="${APP_UID:=0}:${APP_GID:=0}"
  if [ ! -f ${APP_DATA}/config.ini ]; then
    su-exec ${APP_DATA_UIDGID} cp /template/config.ini ${APP_DATA}/
  fi
  if [ $(stat -c "%u:%g" ${APP_DATA}) != "${APP_DATA_UIDGID}" ]; then
    chown -R ${APP_DATA_UIDGID} "$APP_DATA"
  fi

  cd /opt/SickGear

  exec su-exec ${APP_DATA_UIDGID} python "$@" --datadir=$APP_DATA
fi

exec "$@"
