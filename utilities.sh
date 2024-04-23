BACKLIGHT="intel_backlight"

vol_notif() {
	VOL=$(pulsemixer --get-volume | cut -f 1 -d " ")
	notify-send "Volume: $VOL%" -h int:value:"$VOL" -r 1
}

mute_notif() {
	MUTE_STAT=$(pulsemixer --get-mute)
	if [[ $MUTE_STAT == "1" ]]; then
		notify-send "Muted Audio 婢" -r 2
	else
		notify-send "Unmuted Audio 墳" -r 2
	fi
}

light_notif() {
	BRIGHTNESS=$(cat /sys/class/backlight/$BACKLIGHT/brightness)
	MAX_BRIGHTNESS=$(cat /sys/class/backlight/$BACKLIGHT/max_brightness)
	PERCENTAGE=$((BRIGHTNESS * 100 / MAX_BRIGHTNESS))
	
	notify-send "Brightness: $PERCENTAGE%" -h int:value:"$PERCENTAGE" -r 3
}

case "$1" in
	"--upvol" ) pulsemixer --change-volume +1 && pkill -SIGUSR1 -f dwmbar.sh && vol_notif;;
	"--downvol" ) pulsemixer --change-volume -1 && pkill -SIGUSR1 -f dwmbar.sh && vol_notif;;
	"--mutevol" ) pulsemixer --toggle-mute && pkill -SIGUSR1 -f dwmbar.sh && mute_notif;;
	"--uplight" ) brightnessctl s 1%+ && pkill -SIGUSR2 -f dwmbar.sh && light_notif;;
	"--downlight" ) brightnessctl s 1%-  && pkill -SIGUSR2 -f dwmbar.sh && light_notif;;
	"--weather" ) st -c floatst -g 45x8 -e sh -c "curl wttr.in/?0; read";; 
	"--clock" ) st -c floatst -g 56x9 -e sh -c "tty-clock -scC 1";;
	"--neofetch" ) st -c floatst -g 66x16 -e sh -c "neofetch; read";;
esac
