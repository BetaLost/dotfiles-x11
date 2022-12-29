#!/bin/bash

while :; do
	declare -i CUR_BAT=$(cat /sys/class/power_supply/BAT1/capacity | grep -E -o '[0-9]+')
	BAT_STAT=$(cat /sys/class/power_supply/BAT1/status)
	
	if [[ $BAT_STAT == "Charging" ]]; then
		BAT_ICON=""
	elif [[ $CUR_BAT -le 10 ]]; then
		BAT_ICON=""
		notify-send --urgency=critical "$CUR_BAT%: Low Battery!"
	elif [[ $CUR_BAT -ge 10 && $CUR_BAT -le 20 ]]; then
		BAT_ICON=""
		notify-send --urgency=critical "$CUR_BAT%: Low Battery!"
	elif [[ $CUR_BAT -ge 20 && $CUR_BAT -le 30 ]]; then
		BAT_ICON=""
	elif [[ $CUR_BAT -ge 30 && $CUR_BAT -le 40 ]]; then
		BAT_ICON=""
	elif [[ $CUR_BAT -ge 40 && $CUR_BAT -le 50 ]]; then
		BAT_ICON=""	
	elif [[ $CUR_BAT -ge 50 && $CUR_BAT -le 60 ]]; then
		BAT_ICON=""
	elif [[ $CUR_BAT -ge 60 && $CUR_BAT -le 70 ]]; then
		BAT_ICON=""
	elif [[ $CUR_BAT -ge 70 && $CUR_BAT -le 80 ]]; then
		BAT_ICON=""
	elif [[ $CUR_BAT -ge 80 && $CUR_BAT -le 90 ]]; then
		BAT_ICON=""	
	elif [[ $CUR_BAT -ge 90 && $CUR_BAT -le 100 ]]; then
		BAT_ICON=""
	fi
	
	echo "%{T3}%{F#666}$BAT_ICON%{F-}%{T-}  $CUR_BAT%"
	sleep 15
done
