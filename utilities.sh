case "$1" in
	"--upvol" ) pulsemixer --change-volume +1 && pkill -SIGUSR1 -f dwmbar.sh;;
	"--downvol" ) pulsemixer --change-volume -1 && pkill -SIGUSR1 -f dwmbar.sh;;
	"--mutevol" ) pulsemixer --toggle-mute && pkill -SIGUSR1 -f dwmbar.sh;;
	"--uplight" ) brightnessctl s 1%+ && pkill -SIGUSR2 -f dwmbar.sh;;
	"--downlight" ) brightnessctl s 1%-  && pkill -SIGUSR2 -f dwmbar.sh;;
	"--weather" ) st -c floatst -g 45x8 -e sh -c "curl wttr.in/?0; read";; 
	"--clock" ) st -c floatst -g 56x9 -e sh -c "tty-clock -s -c -C 1";;
	"--neofetch" ) st -c floatst -g 66x16 -e sh -c "neofetch; read";;
esac
