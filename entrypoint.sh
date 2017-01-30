#!/bin/sh
set -e

# If we are called with default arguments, invoke SickGear with datadir and
# setup the environment
if [ "$1" = 'SickBeard.py' ]; then
  if [ ! -f ${APP_DATA}/config.ini ]; then
    cp /template/config.ini ${APP_DATA}/
  fi
  # For git, we need to have an user with gid and uid.

  if [ ${APP_GID:=0} -ne 0 ]; then
    groupmod -o -g ${APP_GID} group
  fi
  if [ ${APP_UID:=0} -ne 0 ]; then
    usermod -o -u ${APP_UID} -g ${APP_GID} user
  fi

  # We are in development branch, we need to chown the sickgear installation
  chown -R ${APP_UID}:${APP_GID} /opt/SickGear
  chown -R ${APP_UID}:${APP_GID} "$APP_DATA"

  cd /opt/SickGear

  # update the installation to latest git revision
  gosu $APP_UID:$APP_GID git pull

  gosu $APP_UID:$APP_GID python "$@" --datadir=$APP_DATA &

  while true; do
    sleep 5
  done
fi

exec "$@"
