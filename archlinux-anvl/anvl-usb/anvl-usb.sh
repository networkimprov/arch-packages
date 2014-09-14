#!/bin/bash

#
# Enables consoles and USB gadget configuration, intended to be run
# once at boot.
#

vendor=0x1d6b
product=0x0106
manufacturer="Anvl"
file0=""
omap_dieid=0
usb_controller="musb-hdrc.0.auto"

# 
# Function for initializing USB composite gadget
# Based on the sample configuration at:
# https://wiki.tizen.org/wiki/USB/Linux_USB_Layers/Configfs_Composite_Gadget/Usage_eq._to_g_multi.ko
#
start() {
        modprobe libcomposite > /dev/null 2>&1
        mount -t configfs none /sys/kernel/config > /dev/null 2>&1

	if [ ! -d /sys/kernel/config ]; then
		echo "ERROR: No configfs found"
		return 1
	fi

        mkdir /sys/kernel/config/usb_gadget/g1
        old_pwd=$(pwd)
        cd /sys/kernel/config/usb_gadget/g1
        
        echo $product > idProduct
        echo $vendor > idVendor
        mkdir strings/0x409
        echo $omap_dieid > strings/0x409/serialnumber
        echo $manufacturer > strings/0x409/manufacturer
        echo "Multi Gadget" > strings/0x409/product
        
        mkdir configs/c.1
        echo 120 > configs/c.1/MaxPower
        mkdir configs/c.1/strings/0x409
        echo "Conf 1" > configs/c.1/strings/0x409/configuration
        
        mkdir configs/c.2
        echo 500 > configs/c.2/MaxPower
        mkdir configs/c.2/strings/0x409
        echo "Conf 2" > configs/c.2/strings/0x409/configuration
        
        mkdir functions/mass_storage.0
        echo $file0 > functions/mass_storage.0/lun.0/file
  
        mkdir functions/acm.0
        mkdir functions/ecm.0
        mkdir functions/rndis.0
        
        ln -s functions/rndis.0 configs/c.1
        ln -s functions/acm.0 configs/c.1
        ln -s functions/mass_storage.0 configs/c.1
        
        ln -s functions/ecm.0 configs/c.2
        ln -s functions/acm.0 configs/c.2
        ln -s functions/mass_storage.0 configs/c.2
        
        echo $usb_controller > /sys/kernel/config/usb_gadget/g1/UDC
        cd $old_pwd

	/usr/bin/usb-manager $(find /sys -name vbus | grep twl4030-usb) &
}

stop() {
	killall usb-manager > /dev/null 2>&1
	systemctl stop getty@ttyGS0.service
	if [ ! -d /sys/kernel/config ]; then
		echo "ERROR: No configfs found"
		return 1
	fi
	echo "" > /sys/kernel/config/usb_gadget/g1/UDC
}

case $1 in
	start|stop)
		"$1"
	;;
	*)
		echo "$0 start|stop"
		exit 1
	;;
esac
