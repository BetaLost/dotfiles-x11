#!/bin/bash

while :; do
	VOL=$(pulsemixer --get-volume | cut -f 1 -d " ")
	BRIGHTNESS=$(light)
	CPU=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}')
	CPU_TEMP=$(sed 's/000$/°C/' /sys/class/thermal/thermal_zone0/temp)
	MEMORY=$(free -m | awk '/Mem:/ { print $3 }' | cut -f1 -d 'i')
	CUR_BAT=$(cat /sys/class/power_supply/BAT1/capacity)
	TIME=$(date +"%H:%M")
	DATE=$(date +"%a, %d %B %Y")
	
	MUTE_STAT=$(pulsemixer --get-mute)
	if [[ $BAT_STAT == "Charging" ]]; then
		VOL_ICON="婢"
	else
		VOL_ICON="墳"
	fi
	
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

	R2=`cat /sys/class/net/wlan0/statistics/rx_bytes`
	T2=`cat /sys/class/net/wlan0/statistics/tx_bytes`
	R1=$R2
	T1=$T1
	TBPS=`expr $T2 - $T1`
	RBPS=`expr $R2 - $R1`
	TKBPS=`expr $TBPS / 1024`
	RKBPS=`expr $RBPS / 1024`
	
	xsetroot -name " [ $VOL_ICON $VOL% ] [  ${BRIGHTNESS%.*}% ] [  ${CPU%.*}% ($CPU_TEMP) ] [ RAM $MEMORY MiB ] [  $RKBPS KiB  $TKBPS KiB ] [ $BAT_ICON $CUR_BAT% ] [  $TIME ] [  $DATE ] "
	
	R1=`cat /sys/class/net/wlan0/statistics/rx_bytes`
	T1=`cat /sys/class/net/wlan0/statistics/tx_bytes`
	
	sleep 1
done

