#!/bin/bash
# Injabie3 - 2022-07-09
#
# Description:
# Synology NAS UPS Status Checker
#
# This script polls a USB connected UPS on a Synology NAS. If the server goes on
# battery and reaches the configured threshold, then it will perform a HTTP GET
# request to a shutdown endpoint on a remote device to schedule a power down. If the
# UPS comes back online, it will attempt to cancel the scheduled shutdown (assuming
# the remote device has not already powered off).

# Some config flags
BATTERY_THRESHOLD=70
POLLING_INTERVAL=30

# Read additional settings
source envvar.sh

if [[ -z "${SHUTDOWN_ENDPOINT}" ]]; then
	echo "Missing SHUTDOWN_ENDPOINT variable, please ensure it's set!"
	exit 1
elif [[ -z "${CANCEL_ENDPOINT}" ]]; then
	echo "Missing CANCEL_ENDPOINT variable, please ensure it's set!"
fi


echo Starting UPS script
onBattery=0
triggeredShutdown=0

while true; do
	sleep $POLLING_INTERVAL
	charge=`upsc ups@localhost battery.charge 2> /dev/null`
	status=`upsc ups@localhost ups.status 2> /dev/null`
	echo Battery at ${charge}%

	if [[ $status -eq "OL" ]]; then
		echo "AC online"
		if [[ $triggeredShutdown -eq 1 ]]; then
			echo "Attempting to cancel shutdown"
            wget ${CANCEL_ENDPOINT}
			triggeredShutdown=0
		fi
	else
		echo "AC offline!"
		if [[ ( $charge -le $BATTERY_THRESHOLD ) && ( $triggeredShutdown -eq 0 ) ]]; then
			echo "Triggering remote shutdown"
			wget ${SHUTDOWN_ENDPOINT}
			triggeredShutdown=1
		fi
	fi

done

