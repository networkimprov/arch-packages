#!/bin/sh

set -e

BASE=(/sys/devices/platform/*.ocp/*.i2c/i2c-0/*/twl4030-gpio/gpio/gpiochip*/base)
exec < $BASE
read GPIO

let GPIO+=6

value=0
if [ "$1" = set ]; then
  exec < /sys/class/power_supply/bq24190-charger/f_iinlim
  read IINLIM

  if [ "$IINLIM" = 2 ]; then
    value=1
  fi
fi

DIR=/sys/class/gpio/gpio${GPIO}

echo $GPIO > /sys/class/gpio/export 2> /dev/null || true

echo out > ${DIR}/direction

echo $value > ${DIR}/value

echo "gpio $GPIO set to $value"
