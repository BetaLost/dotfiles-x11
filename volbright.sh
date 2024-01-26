case "$1" in
	"--upvol" ) pulsemixer --change-volume +1 && pkill -SIGUSR1 -f dwmbar.sh;;
	"--downvol" ) pulsemixer --change-volume -1 && pkill -SIGUSR1 -f dwmbar.sh;;
	"--mutevol" ) pulsemixer --toggle-mute && pkill -SIGUSR1 -f dwmbar.sh;;
	"--uplight" ) brightnessctl s 1%+ && pkill -SIGUSR2 -f dwmbar.sh;;
	"--downlight" ) brightnessctl s 1%-  && pkill -SIGUSR2 -f dwmbar.sh;;
esac
