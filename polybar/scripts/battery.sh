#!/bin/bash

while :; do
	declare -i CUR_BAT=$(cat /sys/class/power_supply/BAT1/capacity | grep -E -o '[0-9]+')
	BAT_STAT=$(cat /sys/class/power_supply/BAT1/status)
	
	if [[ $BAT_STAT == "Charging" ]]; then
		BAT_ICON=""
	elif [[ $CUR_BAT -lt 10 ]]; then
		BAT_ICON=""
		notify-send --urgency=critical "$CUR_BAT%: Low Battery!"
	elif [[ $CUR_BAT -gt 10 && $CUR_BAT -lt 20 ]]; then
		BAT_ICON=""
		notify-send --urgency=critical "$CUR_BAT%: Low Battery!"
	elif [[ $CUR_BAT -gt 20 && $CUR_BAT -lt 30 ]]; then
		BAT_ICON=""
	elif [[ $CUR_BAT -gt 30 && $CUR_BAT -lt 40 ]]; then
		BAT_ICON=""
	elif [[ $CUR_BAT -gt 40 && $CUR_BAT -lt 50 ]]; then
		BAT_ICON=""	
	elif [[ $CUR_BAT -gt 50 && $CUR_BAT -lt 60 ]]; then
		BAT_ICON=""
	elif [[ $CUR_BAT -gt 60 && $CUR_BAT -lt 70 ]]; then
		BAT_ICON=""
	elif [[ $CUR_BAT -gt 70 && $CUR_BAT -lt 80 ]]; then
		BAT_ICON=""
	elif [[ $CUR_BAT -gt 80 && $CUR_BAT -lt 90 ]]; then
		BAT_ICON=""	
	elif [[ $CUR_BAT -gt 90 && $CUR_BAT -lt 100 ]]; then
		BAT_ICON=""
	fi
	
	echo "%{T3}%{F#666}$BAT_ICON%{F-}%{T-}  $CUR_BAT%"
	sleep 15
done
