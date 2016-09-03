#!/usr/bin/sh

set -e

if [ "$1" != start -a "$1" != stop ]; then
  echo "Usage: $0 start|stop"
  exit 1
fi

op=$1

timers=(
  systemd-tmpfiles-clean
  logrotate
  man-db
  shadow
  fstrim
  )

for tmr in ${timers[@]}; do
  /usr/bin/systemctl $op ${tmr}.timer
done
