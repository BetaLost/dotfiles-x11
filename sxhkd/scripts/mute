#!/bin/bash

pulsemixer --toggle-mute
MUTE_STAT=$(pulsemixer --get-mute)

if [[ $MUTE_STAT == "0" ]]; then
	echo 0 > /sys/class/leds/hda::mute/brightness
elif [[ $MUTE_STAT == "1" ]]; then
	echo 1 > /sys/class/leds/hda::mute/brightness
fi
