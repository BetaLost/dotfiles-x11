#!/bin/bash

# Kill pre-existing instances of this loop then run a new loop to make sure the compositor is always running
ps fjx | grep "bash -c  while :; do" | awk 'NR>1 {print $2}' | xargs kill
bash -c '
while :; do
	if pgrep -x picom > /dev/null; then
		true
	else
		picom &
	fi
	sleep 30
done &
'

# Set random wallpaper based on time of day and generate colorscheme
TIME=$(date +"%-H")

if [[ $TIME -ge 4 && $TIME -lt 7 ]]; then
	FOLDER=dawn
elif [[ $TIME -ge 7 && $TIME -lt 11 ]]; then
	FOLDER=morning
elif [[ $TIME -ge 11 && $TIME -lt 16 ]]; then
	FOLDER=noon
elif [[ $TIME -ge 16 && $TIME -lt 19 ]]; then
	FOLDER=sunset
elif [[ $TIME -ge 19 ]] || [[ $TIME -lt 4 ]]; then
	FOLDER=night
fi

#WALLPAPER=$(ls -1 $HOME/.config/wallpapers/$FOLDER/ | sort --random-sort | head -1)
wal -i $HOME/.config/wallpapers/$FOLDER/
#feh --bg-scale $HOME/.config/wallpapers/$FOLDER/$WALLPAPER

# Kill pre-existing dwmbar instances then run the dwmbar script
cd $HOME/.config
pkill -f dwmbar.sh
sh dwmbar.sh &

# -- CONFIGURE DWM COLORSCHEME --

# Remove urgent colorscheme
sed -i '9,12d;17d' $HOME/.cache/wal/colors-wal-dwm.h

# Indicate selected tag with a different fg color rather than a different bg color
sel_fg=$(sed -n "10p" < $HOME/.cache/wal/colors)
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

# Build dmenu and make colors match with dwm
sed -i "s/\[SchemeSel\] = { \"\(.*\)\", \"\(.*\)\" },/\[SchemeSel\] = { \"\1\", \"$(awk -F'[] ="]+' '/static const char sel_fg/{print $5}' $HOME/.cache/wal/colors-wal-dwm.h)\" },/" $HOME/.cache/wal/colors-wal-dmenu.h

bg_color=$(awk '/SchemeNorm/ {print $5}' $HOME/.cache/wal/colors-wal-dmenu.h)
bg_color_highlight=$(awk '/SchemeOut/ {print $5}' $HOME/.cache/wal/colors-wal-dmenu.h)

sed -i "s/\[SchemeSel\] = { \(.*\), \(.*\)/\[SchemeSel\] = { $bg_color, \2/" $HOME/.cache/wal/colors-wal-dmenu.h
sed -i "/\[SchemeOut\]/a \ \ \ \ \[SchemeNormHighlight\] = { "$bg_color", "$bg_color_highlight" }," $HOME/.cache/wal/colors-wal-dmenu.h
sed -i "s/\[SchemeOut\]/\[SchemeSelHighlight\]/" $HOME/.cache/wal/colors-wal-dmenu.h

# Configure dunst colors
cp $HOME/.config/dunst/dunstrc.bak $HOME/.config/dunst/dunstrc
sed -i "s/_FRAMECOL_/$sel_fg/" $HOME/.config/dunst/dunstrc
sed -i "s/_BGCOL_/${bg_color//\"/}/" $HOME/.config/dunst/dunstrc
sed -i "s/_HIGHLIGHTCOL_/${bg_color_highlight//\"/}/" $HOME/.config/dunst/dunstrc
sed -i "s/_FGCOL_/$(sed -n "8p" < $HOME/.cache/wal/colors)/" $HOME/.config/dunst/dunstrc

cd $HOME/.config/dmenu && sudo make clean install &

# Build st
cd $HOME/.config/st && sudo make clean install &

# Build dwm
cd $HOME/.config/dwm && sudo make clean install

cd $HOME
exec dwm
