#!/bin/bash

HOME=/home/chief

# Check every 30 seconds to make sure the compositor is always running
while :; do
	if pgrep -x picom > /dev/null; then
		true
	else
		picom &
	fi
	sleep 30
done &

# Kill pre-existing dwmbar instances then run the dwmbar script
cd $HOME/.config
pkill -f dwmbar.sh
sh dwmbar.sh &
cd $HOME

# Set random wallpaper based on time of day and generate colorscheme
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

# -- CONFIGURE DWM COLORSCHEME --

# Remove urgent colorscheme
sed -i '9d;10d;11d;12d;17d' $HOME/.cache/wal/colors-wal-dwm.h

# Indicate selected tag with a different fg color rather than a different bg color
sel_fg=$(sed -n "7p" < $HOME/.cache/wal/colors)
sed -i "s/static const char sel_fg\[\] = \".*\"/static const char sel_fg\[\] = \"$sel_fg\"/" $HOME/.cache/wal/colors-wal-dwm.h
sed -i "s/\[SchemeSel\]  = { sel_fg,      sel_bg,    sel_border },  \/\/ the focused win/\[SchemeSel\]  = { sel_fg,      norm_bg,   sel_border },  \/\/ the focused win/" $HOME/.cache/wal/colors-wal-dwm.h

# Add a colorscheme for inactive tags (dimmed fg)
color=$(grep "char norm_border" $HOME/.cache/wal/colors-wal-dwm.h | awk '{print $6}' | tr -d '";')
factor=0.45

r=$(printf "%d" "0x$(echo $color | cut -c 2-3)")
g=$(printf "%d" "0x$(echo $color | cut -c 4-5)")
b=$(printf "%d" "0x$(echo $color | cut -c 6-7)")

r=$(echo "$r * $factor" | bc | awk '{print int($1+0.5)}')
g=$(echo "$g * $factor" | bc | awk '{print int($1+0.5)}')
b=$(echo "$b * $factor" | bc | awk '{print int($1+0.5)}')

r=$(printf "%02x" "$r")
g=$(printf "%02x" "$g")
b=$(printf "%02x" "$b")
idle_color="$r$g$b"

sed -i "/char norm_border/a static const char idle_fg\[\] = \"#$idle_color\"\;" $HOME/.cache/wal/colors-wal-dwm.h
sed -i "/\[SchemeSel\]/a \ \ \ \ \[SchemeIdle\] = { idle_fg,     norm_bg,   norm_border },  \/\/ inactive tag \(no windows\)" $HOME/.cache/wal/colors-wal-dwm.h

# -- END DWM CONFIGURATION --

# Build dmenu and make bg color match with dwm
 sed -i "s/\[SchemeSel\] = { \"\(.*\)\", \"\(.*\)\" },/\[SchemeSel\] = { \"\1\", \"$(awk -F'[] ="]+' '/static const char sel_fg/{print $5}' $HOME/.cache/wal/colors-wal-dwm.h)\" },/" $HOME/.cache/wal/colors-wal-dmenu.h
cd $HOME/.config/dmenu && sudo make clean install &
cd $HOME

# Build st
cd $HOME/.config/st && sudo make clean install &
cd $HOME

# Build dwm
cd $HOME/.config/dwm && sudo make clean install
cd $HOME

exec dwm
