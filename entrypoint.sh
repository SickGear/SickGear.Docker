#!/bin/sh
set -e

# If we are called with default arguments, invoke SickGear with datadir and
# setup the environment
if [ "$1" = 'SickBeard.py' ]; then
  if [ ! -f ${APP_DATA}/config.ini ]; then
    cp /template/config.ini ${APP_DATA}/
  fi
  chown -R ${APP_UID:=0}:${APP_GID:=0} "$APP_DATA"

  cd /opt/SickGear

  exec gosu $APP_UID:$APP_GID python "$@" --datadir=$APP_DATA
fi

exec "$@"
