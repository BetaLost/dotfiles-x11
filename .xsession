#!/bin/bash

# Check every 30 seconds to make sure the compositor is always running
while :; do
	if pgrep -x compfy > /dev/null; then
		true
	else
		compfy &
	fi
	sleep 30
done &

# Kill pre-existing dwmbar instances then run the dwmbar script
pkill -f dwmbar.sh
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
feh --bg-scale $HOME/.config/wallpapers/$WALLPAPER

# Build st
cd $HOME/.config/st && sudo make clean install &
cd $HOME

# Build dmenu and make bg color match with dwm
 sed -i "s/\[SchemeSel\] = { \"\(.*\)\", \"\(.*\)\" },/\[SchemeSel\] = { \"\1\", \"$(awk -F'[] ="]+' '/static const char sel_bg/{print $5}' $HOME/.cache/wal/colors-wal-dwm.h)\" },/" $HOME/.cache/wal/colors-wal-dmenu.h
cd $HOME/.config/dmenu && sudo make clean install &
cd $HOME

# Build dwm and add scheme for inactive tags
sed -i '17d' $HOME/.cache/wal/colors-wal-dwm.h
sed -i "/\[SchemeSel\]/a \ \ \ \ \[SchemeIdle\] = { norm_border, norm_bg,   norm_border },  \/\/ inactive tag \(no windows\)" $HOME/.cache/wal/colors-wal-dwm.h
cd $HOME/.config/dwm && sudo make clean install
cd $HOME

exec dwm
