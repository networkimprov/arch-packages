#!/bin/sh
# based off of:
# https://wiki.archlinux.org/index.php/Power_management#Hooks_in_.2Fusr.2Flib.2Fsystemd.2Fsystem-sleep
case $1/$2 in
  pre/*)
    echo "Going to $2..."
    ip link set dev mlan0 down
    modprobe -r mwifiex_sdio
    ;;
  post/*)
    echo "Waking up from $2..."
    modprobe mwifiex_sdio
    ip link set dev mlan0 up
    ;;
esac
