#!/bin/bash

for file in `ls /app/liquidsoap/`; do
  ln -sf /app/liquidsoap/${file} /etc/liquidsoap/${file}
done

/etc/init.d/liquidsoap start


envsubst < /settings_local.py > /opt/player/settings_local.py

cd /opt/player || return
source env/bin/activate
./manage.py migrate
redis-server >> /logs/player 2>&1 &
daphne trunk_player.asgi:channel_layer --port 7055 --bind 127.0.0.1 >> /logs/player 2>&1 &
./manage.py runworker >> /logs/player 2>&1 &
./manage.py runworker >> /logs/player 2>&1 &
./manage.py add_transmission_worker >> /logs/player 2>&1 &
./manage.py add_transmission_worker >> /logs/player 2>&1 &
./manage.py runserver 0.0.0.0:8000 >> /logs/player 2>&1 &

/opt/recorder/recorder --config=/app/config/config.json >> /logs/recorder 2>&1 &
sleep 2

if [ "$1" = "test" ]; then
  tail -f -n +1 /logs/*
else
  tail -f -n +1 /logs/* &
  exec "$@"
fi
