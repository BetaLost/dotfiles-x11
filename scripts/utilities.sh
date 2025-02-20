BACKLIGHT="_BACKLIGHT_"
HISTFILE="$HOME/.clipboard_history"
BLUE_MAC_ADDRESS="18:B9:6E:A8:38:CC"

vol_notif() {
	VOL=$(pulsemixer --get-volume | cut -f 1 -d " ")
	dunstify "Volume: $VOL%" -h int:value:"$VOL" -r 1
}

mute_notif() {
	MUTE_STAT=$(pulsemixer --get-mute)
	if [[ $MUTE_STAT == "1" ]]; then
		dunstify "婢 Muted Audio" -r 2
	else
		dunstify "墳 Unmuted Audio" -r 2
	fi
}

light_notif() {
	BRIGHTNESS=$(cat /sys/class/backlight/$BACKLIGHT/brightness)
	MAX_BRIGHTNESS=$(cat /sys/class/backlight/$BACKLIGHT/max_brightness)
	PERCENTAGE=$((BRIGHTNESS * 100 / MAX_BRIGHTNESS))
	
	dunstify "Brightness: $PERCENTAGE%" -h int:value:"$PERCENTAGE" -r 3
}

blue_notif() {
	BLUE_DEV=$(bluetoothctl info | grep -oP 'Name: \K.*')
	
	if [[ -n $BLUE_DEV ]]; then
		BLUE_PERCENTAGE=$(bluetoothctl info | grep "Battery" | awk '{gsub(/[\(\)]/,"",$4); print $4}')
		case $BLUE_PERCENTAGE in
			[0-9]) BLUE_ICON="󰤾";;
			[1][0-9]) BLUE_ICON="󰤿";;
			[2][0-9]) BLUE_ICON="󰥀";;
			[3][0-9]) BLUE_ICON="󰥁";;
			[4][0-9]) BLUE_ICON="󰥂";;
			[5][0-9]) BLUE_ICON="󰥃";;
			[6][0-9]) BLUE_ICON="󰥄";;
			[7][0-9]) BLUE_ICON="󰥅";;
			[8][0-9]) BLUE_ICON="󰥆";;
			[9][0-9] | 100) BLUE_ICON="󰥈";;
		esac
	
		dunstify "$BLUE_ICON $BLUE_DEV Charge: $BLUE_PERCENTAGE%" -h int:value:"$BLUE_PERCENTAGE" -r 5
	else
		dunstify "󰂲 No bluetooth device connected" -r 5
	fi
}

case "$1" in
	"--upvol" ) pulsemixer --change-volume +1 && pkill -SIGUSR1 -f dwmbar.sh && vol_notif;;
	"--downvol" ) pulsemixer --change-volume -1 && pkill -SIGUSR1 -f dwmbar.sh && vol_notif;;
	"--mutevol" ) pulsemixer --toggle-mute && pkill -SIGUSR1 -f dwmbar.sh && mute_notif;;
	"--uplight" ) brightnessctl s 1%+ && pkill -SIGUSR2 -f dwmbar.sh && light_notif;;
	"--downlight" ) brightnessctl s 1%-  && pkill -SIGUSR2 -f dwmbar.sh && light_notif;;
	"--connectblue" ) bluetoothctl power on; bluetoothctl agent on; bluetoothctl default-agent; bluetoothctl disconnect $BLUE_MAC_ADDRESS; bluetoothctl connect $BLUE_MAC_ADDRESS;;
	"--checkbat" ) blue_notif;;
	"--emojis" ) printf "$(cat $HOME/.config/scripts/emojis.txt | dmenu -i -c -l 10 -p 'Emojis')" | awk '{printf $1}' | xclip -sel c;;
	"--clipboard" ) sed -i '${/^[[:space:]]*$/d;}' $HISTFILE; cat $HISTFILE | dmenu -i -c -l 10 -p "Clipboard" | tr -d '\n' |  xclip -sel c;;
	"--weather" ) st -c floatst -g 45x8 -e sh -c "curl wttr.in/?0; read";; 
	"--clock" ) st -c floatst -g 56x9 -e sh -c "tty-clock -scC 1";;
	"--neofetch" ) st -c floatst -g 66x16 -e sh -c "neofetch; read";;
esac
