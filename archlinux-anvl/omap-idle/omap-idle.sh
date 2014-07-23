#!/bin/bash

#
# Enables deeper idle modes for omaps, intended to be run
# once at boot.
#

uarts=$(find /sys/class/tty/ttyO*/device/power/ -type d)

start() {
	for uart in $uarts; do
		if ! echo 3000 > $uart/autosuspend_delay_ms; then
			exit 1
		fi
	done

	uarts=$(/usr/bin/find /sys/class/tty/ttyO*/power/ -type d)
	for uart in $uarts; do
		if ! echo enabled > $uart/wakeup; then
			exit 2
		fi
		if ! echo auto > $uart/control; then
			exit 3
		fi
	done

	if ! echo 1 > /sys/kernel/debug/pm_debug/enable_off_mode; then
		exit 4
	fi
}

stop() {
	if ! echo 0 > /sys/kernel/debug/pm_debug/enable_off_mode; then
		exit 1
	fi

	for uart in $uarts; do
		if ! echo -1 > $uart/autosuspend_delay_ms; then
			exit 2
		fi
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
