#!/bin/bash

# Make sure picom is always running
while :; do
	if pgrep -x picom > /dev/null; then
		true
	else
		picom &
	fi
	sleep 5
done &

# Run dwmbar script
sh dwmbar.sh &

# Set random wallpaper
HOME=/home/chief
file=$(ls -1 $HOME/.config/wallpapers/ | sort --random-sort | head -1)
wal -i $HOME/.config/wallpapers/$file

cd $HOME/.config/st && sudo make clean install &
cd $HOME

cd $HOME/.config/dmenu && sudo make clean install &
cd $HOME

sed -i '17d' $HOME/.cache/wal/colors-wal-dwm.h
cd $HOME/.config/dwm && sudo make clean install
cd $HOME

feh --bg-scale $HOME/.config/wallpapers/$file
exec dwm
