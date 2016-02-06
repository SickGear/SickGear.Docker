#!/bin/sh
set -e

if [ "$1" = 'SickBeard.py' ]; then
    chown -R ${APP_UID:=0}:${APP_GID:=0} "$APP_DATA"

    exec gosu $APP_UID:$APP_GID python "$@" --datadir=$APP_DATA
fi

exec "$@"
