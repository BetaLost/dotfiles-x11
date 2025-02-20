#!/bin/bash

# Scripts directory
SCRIPTS="$HOME/.config/scripts"

# Hardware
BACKLIGHT="_BACKLIGHT_"
NET_INTERFACE="_NET_"

# Set colorscheme
icon_bg=$(sed -n "10p" < $HOME/.cache/wal/colors)
text_bg=$(sed -n "8p" < $HOME/.cache/wal/colors)
text_fg=$(sed -n "1p" < $HOME/.cache/wal/colors)
icon_scheme="^c$text_fg^^b$icon_bg^"
text_scheme="^d^^c$text_fg^^b$text_bg^"

update_volume() {
	VOL=$(pulsemixer --get-volume | cut -f 1 -d " ")
	
	MUTE_STAT=$(pulsemixer --get-mute)
	if [[ $MUTE_STAT == "1" ]] then VOL_ICON="婢"; else VOL_ICON="墳"; fi
	
	echo "$icon_scheme^l^$VOL_ICON $text_scheme $VOL%^e^^d^"
}

update_brightness() {
	BRIGHTNESS=$(cat /sys/class/backlight/$BACKLIGHT/brightness)
	MAX_BRIGHTNESS=$(cat /sys/class/backlight/$BACKLIGHT/max_brightness)
	PERCENTAGE=$((BRIGHTNESS * 100 / MAX_BRIGHTNESS))
	
	if [[ $PERCENTAGE -le 20 ]]; then
		BRIGHT_ICON="󰃞"
	elif [[ $PERCENTAGE -gt 20 && $PERCENTAGE -lt 50 ]]; then
		BRIGHT_ICON="󰃝"
	elif [[ $PERCENTAGE -ge 50 && $PERCENTAGE -lt 75 ]]; then
		BRIGHT_ICON="󰃟"
	elif [[ $PERCENTAGE -ge 75 ]]; then
		BRIGHT_ICON="󰃠"
	fi
	
	echo "$icon_scheme^l^$BRIGHT_ICON $text_scheme ${PERCENTAGE%.*}%^e^^d^"
}

update_cpu() {
	CPUSTAT=$(grep 'cpu ' /proc/stat)
	
	IDLE2=$(echo "$CPUSTAT" | awk '{print $5}')
	TOTAL2=$(echo "$CPUSTAT" | awk '{total = $2 + $3 + $4 + $5 + $6 + $7 + $8} END {print total}')
	
	IDLE_DIFF=$((IDLE2 - IDLE1))
	TOTAL_DIFF=$((TOTAL2 - TOTAL1))
	
	CPU_USAGE=$(awk "BEGIN {print (1 - $IDLE_DIFF / $TOTAL_DIFF) * 100}")
	
	if ((cpu_toggle)); then
		echo "$icon_scheme^l^ $text_scheme ${CPU_USAGE%.*}%^e^^d^"
	else
		CPU_TEMP=$(sed 's/000$/°C/' /sys/class/thermal/thermal_zone0/temp)
		echo "$icon_scheme^l^ $text_scheme ${CPU_USAGE%.*}% ($CPU_TEMP)^e^^d^"
	fi
}

update_ram() {
	MEMORY=$(free -m | awk '/Mem:/ { print $3 }' | cut -f1 -d 'i')
	
	if ((ram_toggle)); then
		echo "$icon_scheme^l^RAM $text_scheme $MEMORY MiB^e^^d^"
	else
		if ((MEMORY > 1024)); then
			MEMORY=$(echo "scale=2; $MEMORY / 1024" | bc)
			echo "$icon_scheme^l^RAM $text_scheme $MEMORY GiB^e^^d^"
		else
			echo "$icon_scheme^l^RAM $text_scheme $MEMORY MiB^e^^d^"
		fi
	fi
}

update_net() {
	R2=`cat /sys/class/net/$NET_INTERFACE/statistics/rx_bytes`
	T2=`cat /sys/class/net/$NET_INTERFACE/statistics/tx_bytes`
	TBPS=$((T2 - T1))
	RBPS=$((R2 - R1))
	TKBPS=$((TBPS / 1024))
	RKBPS=$((RBPS / 1024))
	
	if ((net_toggle || (TKBPS == 0 && RKBPS == 0))); then
		SSID=$(iwgetid -r)
		if [[ -z $SSID ]] then SSID="No Internet"; fi
		echo "$icon_scheme^l^󰖩 $text_scheme $SSID^e^^d^"
	else
		if ((RKBPS > 1024)); then
			RKBPS=$(echo "scale=2; $RKBPS / 1024" | bc)
			UP="$RKBPS MiB"
		else
			UP="$RKBPS KiB"
		fi
		
		if ((TKBPS > 1024)); then
			TKBPS=$(echo "scale=2; $TKBPS / 1024" | bc)
			DOWN="$TKBPS MiB"
		else
			DOWN="$TKBPS KiB"
		fi
		
		echo "$icon_scheme^l^ $text_scheme $UP ^d^$icon_scheme  $text_scheme $DOWN^e^^d^"
	fi
}

update_bat() {
	CUR_BAT=$(cat /sys/class/power_supply/BAT*/capacity)
	BAT_STAT=$(cat /sys/class/power_supply/BAT*/status)
	
	if [[ $BAT_STAT == "Charging" ]]; then
		BAT_ICON="";
		
		if [[ $PREV_BAT_STAT == "Discharging" && $CUR_BAT < 20 ]]; then
			dunstctl close
		fi
	else
		case $CUR_BAT in
			[0-9]) BAT_ICON=""; dunstify --urgency=critical "$BAT_ICON $CUR_BAT%: Low Battery!" -r 4;;
			[1][0-9]) BAT_ICON=""; dunstify --urgency=critical "$BAT_ICON $CUR_BAT%: Low Battery!" -r 4;;
			[2][0-9]) BAT_ICON="";;
			[3][0-9]) BAT_ICON="";;
			[4][0-9]) BAT_ICON="";;
			[5][0-9]) BAT_ICON="";;
			[6][0-9]) BAT_ICON="";;
			[7][0-9]) BAT_ICON="";;
			[8][0-9]) BAT_ICON="";;
			[9][0-9] | 100) BAT_ICON="";;
		esac
	fi
		
	if ((battery_toggle)); then
		CHARGE=$(cat /sys/class/power_supply/BAT*/charge_now)
		CURRENT=$(cat /sys/class/power_supply/BAT*/current_now)
		VOLTAGE=$(cat /sys/class/power_supply/BAT*/voltage_now)
		DRAW=$((CURRENT * VOLTAGE))
		DRAW=$(echo $DRAW | awk '{printf "%.1f", $1 / 1000000000000 }')
		
		HOURS_REMAINING=$(echo "scale=2; $CHARGE / $CURRENT" | bc)
		HOURS=$(printf "%.0f" $HOURS_REMAINING)
		MINUTES=$(printf "%.0f" $(echo "($HOURS_REMAINING - $HOURS) * 60" | bc))
		
		if ((MINUTES < 0)); then
			((HOURS--))
			((MINUTES += 60))
		fi
		
		if ((HOURS == 0)); then
			echo "$icon_scheme^l^$BAT_ICON $text_scheme $DRAW W ($MINUTES mins)^e^^d^"
		else
			TIME_REMAINING=$(printf "%02d:%02d" $HOURS $MINUTES)
			echo "$icon_scheme^l^$BAT_ICON $text_scheme $DRAW W ($TIME_REMAINING)^e^^d^"
		fi
	else
		echo "$icon_scheme^l^$BAT_ICON $text_scheme $CUR_BAT%^e^^d^"
	fi
}

update_time() {
	if ((time_toggle)); then
		TIME=$(date +"%l:%M %p" | awk '{$1=$1};1')
	else
		TIME=$(date +"%H:%M")
	fi
	
	HOUR=$(date +"%I")
	
	case $HOUR in
		12) TIME_ICON="󱑖";; 01) TIME_ICON="󱑋";; 02) TIME_ICON="󱑌";; 03) TIME_ICON="󱑍";;
		04) TIME_ICON="󱑎";; 05) TIME_ICON="󱑏";; 06) TIME_ICON="󱑐";; 07) TIME_ICON="󱑑";;
		08) TIME_ICON="󱑒";; 09) TIME_ICON="󱑓";; 10) TIME_ICON="󱑔";; 11) TIME_ICON="󱑕";;
	esac
	
	echo "$icon_scheme^l^$TIME_ICON $text_scheme $TIME^e^^d^"
}

vol_sig() {
	volume_section=$(update_volume)
	update_status 0 0 0
}

light_sig() {
	light_section=$(update_brightness)
	update_status 0 0 0
}

# Handle volume and brightness signals
trap "vol_sig" SIGUSR1
trap "light_sig" SIGUSR2

# Ignore signals from the brightness section
trap "" SIGRTMIN+2

# Toggle volume section
trap "bash $SCRIPTS/utilities.sh --mutevol" SIGRTMIN+1

# Toggle CPU section
cpu_toggle=0
trap "if ((cpu_toggle)) then cpu_toggle=0; else cpu_toggle=1; fi; update_status 1 0 0" SIGRTMIN+3

# Toggle RAM section
ram_toggle=0
trap "if ((ram_toggle)) then ram_toggle=0; else ram_toggle=1; fi; update_status 1 0 0" SIGRTMIN+4

# Toggle network section
net_toggle=0
trap "if ((net_toggle)) then net_toggle=0; else net_toggle=1; fi; update_status 1 0 0" SIGRTMIN+5

# Toggle battery section
battery_toggle=0
trap "if ((battery_toggle)) then battery_toggle=0; else battery_toggle=1; fi; update_status 0 1 0" SIGRTMIN+6

# Toggle prayer section
prayer_toggle=0
trap "if ((prayer_toggle)) then prayer_toggle=0; else prayer_toggle=1; fi; update_status 0 0 1" SIGRTMIN+7

# Toggle time section
time_toggle=0
trap "if ((time_toggle)) then time_toggle=0; else time_toggle=1; fi; update_status 1 0 0" SIGRTMIN+8

# Toggle date section
date_toggle=0
trap "if ((date_toggle)) then date_toggle=0; else date_toggle=1; fi; update_status 1 0 0" SIGRTMIN+9

# Power Menu
power_menu() {
	ACTION=$(printf "⏻ Shutdown\n Reboot\n󰤄 Sleep" | dmenu -i -c -d -l 3 -z 250 -p "󰐦 Power Menu")
	
	if [[ $ACTION == "⏻ Shutdown" ]]; then
		shutdown now
	elif [[ $ACTION == " Reboot" ]]; then
		reboot
	elif [[ $ACTION == "󰤄 Sleep" ]]; then
		systemctl suspend
	fi
}

trap "power_menu &" SIGRTMIN+16

# Initialize volume and brightness sections
volume_section=$(update_volume)
light_section=$(update_brightness)

# Initialize network data
R1=`cat /sys/class/net/$NET_INTERFACE/statistics/rx_bytes`
T1=`cat /sys/class/net/$NET_INTERFACE/statistics/tx_bytes`

# Initialize counters
main_count=0
all_count=0
bat_count=0
prayer_count=0

# Power section
power_section="$icon_scheme^l^ 󰐦 ^e^^d^"

# Arguments (0, 1): main info, battery, prayer time
update_status(){
	# Update main info
	if [ "$1" = 1 ]; then
		cpu_section=$(update_cpu)
		ram_section=$(update_ram)
		net_section=$(update_net)
		time_section=$(update_time)
		
		if ((date_toggle)) then DATE="$HIJRI_DATE"; else DATE=$(date +"%a, %d %B %Y"); fi
		date_section="$icon_scheme^l^ $text_scheme $DATE^e^^d^"
	fi
	
	# Update Battery
	if [ "$2" = 1 ]; then
		bat_section=$(update_bat)
		PREV_BAT_STAT=$(cat /sys/class/power_supply/BAT*/status)
	fi
	
	# Update Prayer Time
	if [ "$3" = 1 ]; then
		if ((prayer_toggle)) then PRAYER_NAME=$(bash $SCRIPTS/prayer.sh -r); else PRAYER_NAME=$(bash $SCRIPTS/prayer.sh -n); fi
		prayer_section="$icon_scheme^l^󰥹 $text_scheme $PRAYER_NAME^e^^d^"
	fi
	
	# Draw Status
	STATUS=$(printf ' \x01%s \x02%s \x03%s \x04%s \x05%s \x06%s \x07%s \x08%s \x09%s\x10 %s ' "$volume_section" "$light_section" "$cpu_section" "$ram_section" "$net_section" "$bat_section" "$prayer_section" "$time_section" "$date_section" "$power_section")
	xsetroot -name "$STATUS"
}

# Initialize status
update_status 1 1 1

# Get Hijri date
HIJRI_DATE=$(bash $SCRIPTS/prayer.sh -h)

# Assign initial bluetooth device and audio sink
PREV_BLUE_DEV=$(bluetoothctl info | grep -oP 'Name: \K.*')
PREV_SINK_ID=$(pulsemixer --list-sinks | awk '/Default/ {split($3,a,","); print a[1]}')

while :; do
	# Increment counters and check bluetooth connection every second
	if ((main_count < SECONDS)); then
		main_count=$SECONDS
		((all_count++))
		((bat_count++))
		((prayer_count++))
		
		# Check if a bluetooth device is connected
		BLUE_DEV=$(bluetoothctl info | grep -oP 'Name: \K.*')
		
		if [[ -n $BLUE_DEV && -z $PREV_BLUE_DEV ]]; then
			dunstify "󰥰 Connected: $BLUE_DEV"
		elif [[ -z $BLUE_DEV && -n $PREV_BLUE_DEV ]]; then
			dunstify "󰽟 Disconnected: $PREV_BLUE_DEV"
		fi
		
		PREV_BLUE_DEV=$BLUE_DEV
		
		# Check if the audio sink was changed
		CURRENT_SINK_ID=$(pulsemixer --list-sinks | awk '/Default/ {split($3,a,","); print a[1]}')
		if [[ $CURRENT_SINK_ID != $PREV_SINK_ID ]]; then vol_sig; fi
		PREV_SINK_ID=$CURRENT_SINK_ID
	fi
	
	# Update battery info every 5 seconds
	if ((bat_count == 5)); then
		update_status 0 1 0
		bat_count=0
	fi
	
	# Update all other info every 3 seconds
	if ((all_count == 3)); then
		update_status 1 0 0
		
		R1=`cat /sys/class/net/$NET_INTERFACE/statistics/rx_bytes`
		T1=`cat /sys/class/net/$NET_INTERFACE/statistics/tx_bytes`
		
		CPUSTAT=$(grep 'cpu ' /proc/stat)
		IDLE1=$(echo "$CPUSTAT" | awk '{print $5}')
		TOTAL1=$(echo "$CPUSTAT" | awk '{total = $2 + $3 + $4 + $5 + $6 + $7 + $8} END {print total}')
		
		all_count=0
	fi
	
	# Update prayer time every 30 seconds
	if ((prayer_count == 30)); then
		update_status 0 0 1
		prayer_count=0
	fi
	
	# Limit CPU usage
	sleep 0.1
done

