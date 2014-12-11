#!/usr/bin/bash

echo "module mwifiex +p"      > /sys/kernel/debug/dynamic_debug/control
echo "module mwifiex_sdio +p" > /sys/kernel/debug/dynamic_debug/control
echo "module mwifiex_pcie +p" > /sys/kernel/debug/dynamic_debug/control
echo "module mwifiex_usb +p"  > /sys/kernel/debug/dynamic_debug/control

