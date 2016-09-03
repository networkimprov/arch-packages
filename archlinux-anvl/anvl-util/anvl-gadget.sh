#!/bin/sh

set -e

make_configs() {
  modprobe -a phy_twl4030_usb omap2430

  mkdir /sys/kernel/config/usb_gadget/g1
  cd /sys/kernel/config/usb_gadget/g1

  vendor=0x1d6b # Linux Foundation
  product=0x0106 # composite gadget
  device=0x0100 # v1.0.0
  usb=0x0200 # USB2

  echo "$product" > idProduct
  echo "$vendor" > idVendor
  echo "$device" > bcdDevice
  echo "$usb" > bcdUSB

  mkdir strings/0x409
  echo "$serialno" > strings/0x409/serialnumber
  echo "Anvl" > strings/0x409/manufacturer
  echo "Multi Gadget" > strings/0x409/product

  mkdir functions/acm.0 # creates /dev/ttyGS0
  mkdir functions/ecm.0
  #mkdir functions/rndis.0
  if [ "$storage" ]; then
    mkdir functions/mass_storage.0
    echo "$storage" > functions/mass_storage.0/lun.0/file
  fi

  cname=configs/c.1
  mkdir -p ${cname}/strings/0x409
  echo "Conf 1" > ${cname}/strings/0x409/configuration
  #echo 120 > ${cname}/MaxPower
  ln -s functions/ecm.0 ${cname}
  ln -s functions/acm.0 ${cname}
  if [ -d functions/mass_storage.0 ]; then
    ln -s functions/mass_storage.0 ${cname}
  fi

  #cname=configs/c.2
  #mkdir -p ${cname}/strings/0x409
  #echo "Conf 2" > ${cname}/strings/0x409/configuration
  #echo 500 > ${cname}/MaxPower

  if ! echo 'musb-hdrc.0.auto' > UDC; then
    return 1
  fi
}

free_configs() {
  cd /sys/kernel/config/usb_gadget/g1
  rm configs/*/*.0 # clears UDC
  rmdir configs/*/strings/0x* configs/* functions/*.0 strings/0x* ../g1
}

if [ "$USER" != root ]; then
  echo "Start with sudo" >&2
  exit 1
elif [ "$1" = start -a $# -le 3 ]; then
  if [ -d /sys/kernel/config/usb_gadget/g1 ]; then
    echo "Already started"
    exit 0
  fi
  if [ $# -ge 2 ]; then
    if [ $# -ge 3 ]; then storage="$3"; fi
    serialno="$2"
  else
    serialno=noserialnumber
  fi
  if ! make_configs; then
    free_configs
    echo "$0 failed in make_configs" >&2
    exit 1
  fi
elif [ "$1" = stop -a $# = 1 ]; then
  if [ ! -d /sys/kernel/config/usb_gadget/g1 ]; then
    echo "Already stopped"
    exit 0
  fi
  free_configs
else
  echo "Usage:" >&2
  echo "$0 start [serialno [storage]]" >&2
  echo "$0 stop" >&2
  exit 1
fi
