#!/bin/sh

set -e

if [ "$USER" != root ]; then
  echo "Start with sudo"
  exit 1
elif [ "$1" = stop -a $# = 1 ]; then
  if [ ! -d /sys/kernel/config/usb_gadget/g1 ]; then
    echo "Already stopped"
    exit 1
  fi
  echo > /sys/kernel/config/usb_gadget/g1/UDC
  rm -rf /sys/kernel/config/usb_gadget/g1
  exit 0;
elif [ "$1" != start -a "$1" != pause ] || [ $# -gt 3 ]; then
  echo "Usage: $0 start|pause [serialno [storage]] ; $0 stop"
  exit 1
fi

vendor=0x1d6b # Linux Foundation
product=0x0106 # composite gadget
device=0x0100 # v1.0.0
usb=0x0200 # USB2

if [ "$2" ]; then
  serialno="$2"
  if [ "$3" ]; then
    storage="$3"
  fi
else
  serialno=noserialnumber
fi

if [ ! -d /sys/kernel/config/usb_gadget/g1 ]; then
  if [ ! -d /sys/kernel/config ]; then
    mount -t configfs none /sys/kernel/config
  fi
  mkdir /sys/kernel/config/usb_gadget/g1
  cd /sys/kernel/config/usb_gadget/g1

  echo "$product" > idProduct
  echo "$vendor" > idVendor
  echo "$device" > bcdDevice
  echo "$usb" > bcdUSB

  mkdir strings/0x409
  echo "$serialno" > strings/0x409/serialnumber
  echo "Anvl" > strings/0x409/manufacturer
  echo "Multi Gadget" > strings/0x409/product

  mkdir functions/acm.0
  mkdir functions/ecm.0
  mkdir functions/rndis.0
  if [ "$storage" ]; then
    mkdir functions/mass_storage.0
    echo "$storage" > functions/mass_storage.0/lun.0/file
  fi

  mkdir -p configs/c.1/strings/0x409
  echo "Conf 1" > configs/c.1/strings/0x409/configuration
  ln -s functions/rndis.0 configs/c.1
  ln -s functions/acm.0 configs/c.1
  if [ "$storage" ]; then
    ln -s functions/mass_storage.0 configs/c.1
  fi
  #echo 120 > configs/c.1/MaxPower

  mkdir -p configs/c.2/strings/0x409
  echo "Conf 2" > configs/c.2/strings/0x409/configuration
  ln -s functions/ecm.0 configs/c.2
  ln -s functions/acm.0 configs/c.2
  if [ "$storage" ]; then
    ln -s functions/mass_storage.0 configs/c.2
  fi
  #echo 500 > configs/c.2/MaxPower
fi

if [ "$1" = pause ]; then
  echo > /sys/kernel/config/usb_gadget/g1/UDC
else
  echo "musb-hdrc.0.auto" > /sys/kernel/config/usb_gadget/g1/UDC
fi
