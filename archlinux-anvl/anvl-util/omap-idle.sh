#!/bin/bash

#
# Enables deeper idle modes for omaps, intended to be run
# once at boot.
#

uarts=$(find /sys/class/tty/tty[SO]*/device/power/ -type d)

start() {
	for uart in $uarts; do
		echo 3000 > $uart/autosuspend_delay_ms 2>/dev/null
	done

	uarts=$(/usr/bin/find /sys/class/tty/tty[SO]*/power/ -type d)
	for uart in $uarts; do
		echo enabled > $uart/wakeup 2>/dev/null
		echo auto > $uart/control 2>/dev/null
	done

	echo 1 > /sys/kernel/debug/pm_debug/enable_off_mode 2>/dev/null
}

stop() {
	echo 0 > /sys/kernel/debug/pm_debug/enable_off_mode 2>/dev/null

	for uart in $uarts; do
		echo -1 > $uart/autosuspend_delay_ms 2>/dev/null
	done
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
