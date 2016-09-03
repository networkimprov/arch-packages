#!/bin/bash

set -e

exec 2> /dev/console

case "$BATTERY_STATE" in
'Charging')
  color=blue  ; on=500 ; off=500 ;;
'Discharging')
  color=green ; on=70  ; off=2930 ;;
'Full')
  color=green ; on=850 ; off=150 ;;
'Not charging')
  color=red   ; on=70  ; off=2390 ;;
'None')
  color=none ;;
*)
  echo "$0: invalid BATTERY_STATE: $BATTERY_STATE" >&2
  exit 1 ;;
esac

led="/sys/class/leds/pca963x:"

echo 0 > "${led}green/brightness"
echo 0 > "${led}blue/brightness"
echo 0 > "${led}red/brightness"

if [ $color = none ]; then
  echo none > "${led}green/trigger"
  echo none > "${led}blue/trigger"
  echo none > "${led}red/trigger"
else
  echo 30 > ${led}${color}/brightness
  echo timer > "${led}${color}/trigger"
  echo $on   > "${led}${color}/delay_on"
  echo $off  > "${led}${color}/delay_off"
fi

