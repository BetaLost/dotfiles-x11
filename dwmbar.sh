#!/bin/bash

update_volume() {
	VOL=$(pulsemixer --get-volume | cut -f 1 -d " ")
	
	MUTE_STAT=$(pulsemixer --get-mute)
	if [[ $MUTE_STAT == "1" ]]; then
		VOL_ICON="婢"
	else
		VOL_ICON="墳"
	fi
	
	echo "[ $VOL_ICON $VOL% ]"
}

update_brightness() {
	BRIGHTNESS=$(cat /sys/class/backlight/intel_backlight/brightness)
	MAX_BRIGHTNESS=$(cat /sys/class/backlight/intel_backlight/max_brightness)
	PERCENTAGE=$((BRIGHTNESS * 100 / MAX_BRIGHTNESS))
	
	echo "[  ${PERCENTAGE%.*}% ]"
}

update_cpu() {
	CPU=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}')
	CPU_TEMP=$(sed 's/000$/°C/' /sys/class/thermal/thermal_zone0/temp)
	
	echo "[  ${CPU%.*}% ($CPU_TEMP) ]"
}

update_ram() {
	MEMORY=$(free -m | awk '/Mem:/ { print $3 }' | cut -f1 -d 'i')
	
	echo "[ RAM $MEMORY MiB ]"
}

update_net() {
	if [[ -z $T1 ]]; then
		R1=`cat /sys/class/net/wlan0/statistics/rx_bytes`
		T1=`cat /sys/class/net/wlan0/statistics/tx_bytes`
	fi
	
	R2=`cat /sys/class/net/wlan0/statistics/rx_bytes`
	T2=`cat /sys/class/net/wlan0/statistics/tx_bytes`
	TBPS=`expr $T2 - $T1`
	RBPS=`expr $R2 - $R1`
	TKBPS=`expr $TBPS / 1024`
	RKBPS=`expr $RBPS / 1024`
	
	echo "[  $RKBPS KiB  $TKBPS KiB ]"
}

update_bat() {
	CUR_BAT=$(cat /sys/class/power_supply/BAT1/capacity)
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
	
	echo "[ $BAT_ICON $CUR_BAT% ]"
}

vol_sig() {
	volume_section=$(update_volume)
	xsetroot -name " $volume_section $light_section $cpu_section $ram_section $net_section $bat_section [  $TIME ] [  $DATE ] "
}

light_sig() {
	light_section=$(update_brightness)
	xsetroot -name " $volume_section $light_section $cpu_section $ram_section $net_section $bat_section [  $TIME ] [  $DATE ] "
}

trap "vol_sig" SIGUSR1
trap "light_sig" SIGUSR2

# Initialize volume and brightness sections
volume_section=$(update_volume)
light_section=$(update_brightness)

# Initialize counters
bat_count=0
all_count=0

# Initialize all other sections
cpu_section=$(update_cpu)
ram_section=$(update_ram)
net_section=$(update_net)
bat_section=$(update_bat)
TIME=$(date +"%H:%M")
DATE=$(date +"%a, %d %B %Y")

while :; do
	# Update battery info every 3 seconds
	if ((bat_count == 3)); then
		bat_section=$(update_bat)
		bat_count=0
	fi
	
	# Update all other info every second
	if ((all_count < SECONDS)); then
		cpu_section=$(update_cpu)
		ram_section=$(update_ram)
		net_section=$(update_net)
		TIME=$(date +"%H:%M")
		DATE=$(date +"%a, %d %B %Y")
		
		all_count=$SECONDS
		((bat_count++))
		
		R1=`cat /sys/class/net/wlan0/statistics/rx_bytes`
		T1=`cat /sys/class/net/wlan0/statistics/tx_bytes`
	fi
		
	xsetroot -name " $volume_section $light_section $cpu_section $ram_section $net_section $bat_section [  $TIME ] [  $DATE ] "
done

