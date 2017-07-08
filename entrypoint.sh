#!/bin/sh
set -e

# If we are called with default arguments, invoke SickGear with datadir and
# setup the environment
if [ "$1" = 'SickBeard.py' ]; then
  if [ ! -f ${APP_DATA}/config.ini ]; then
    exec gosu ${APP_UID:=0}:${APP_GID:=0} cp /template/config.ini ${APP_DATA}/
  fi
  CFG_DIR_UID=`ls -lnd "$APP_DATA" | awk 'NR==1 {print $3}'`
  CFG_DIR_GID=`ls -lnd "$APP_DATA" | awk 'NR==1 {print $4}'`
  if [ $APP_UID -ne $CFG_DIR_UID ] && [ $APP_GID -ne $CFG_DIR_GID ]; then
    chown -R ${APP_UID:=0}:${APP_GID:=0} "$APP_DATA"
  fi

  cd /opt/SickGear

  exec gosu ${APP_UID:=0}:${APP_GID:=0} python "$@" --datadir=$APP_DATA
fi

exec "$@"
