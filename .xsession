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

# Set random wallpaper based on time of day
HOME=/home/chief
TIME=$(date +"%H")

if [[ $TIME -ge 4 && $TIME -lt 6 ]]; then
	FOLDER=dawn
elif [[ $TIME -ge 6 && $TIME -lt 11 ]]; then
	FOLDER=morning
elif [[ $TIME -ge 11 && $TIME -lt 16 ]]; then
	FOLDER=noon
elif [[ $TIME -ge 16 && $TIME -lt 19 ]]; then
	FOLDER=sunset
elif [[ $TIME -ge 19 ]] || [[ $TIME -lt 4 ]]; then
	FOLDER=night
fi

WALLPAPER=$(ls -1 $HOME/.config/wallpapers/$FOLDER/ | sort --random-sort | head -1)
wal -i $HOME/.config/wallpapers/$FOLDER/$WALLPAPER

cd $HOME/.config/st && sudo make clean install &
cd $HOME

cd $HOME/.config/dmenu && sudo make clean install &
cd $HOME

sed -i '17d' $HOME/.cache/wal/colors-wal-dwm.h
cd $HOME/.config/dwm && sudo make clean install
cd $HOME

feh --bg-scale $HOME/.config/wallpapers/$WALLPAPER
exec dwm
