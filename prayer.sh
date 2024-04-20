#!/bin/bash

CITY=""
COUNTRY=""

CURRENT_TIME=$(date +"%H:%M")
CURRENT_DATE=$(date +"%d-%m-%Y")

if [[ ! -f "$HOME/.config/prayerhistory/$CURRENT_DATE.txt" ]]; then
	TIMINGS=$(curl -Ls "http://api.aladhan.com/v1/timingsByCity?city=$CITY&country=$COUNTRY&method=4&adjustment=1" | jq ".data.timings" | sed "1d;6d;9,13d")
	echo "$TIMINGS" > "$HOME/.config/prayerhistory/$CURRENT_DATE.txt"
fi

while IFS= read -r line; do 
	PRAYER_NAME=$(echo $line | awk '{print $1}' | cut -d '"' -f2)
	PRAYER_TIME=$(echo $line | awk '{print $2}' | cut -d '"' -f2)
	
	if [[ "$CURRENT_TIME" == "$PRAYER_TIME" ]]; then
		CURRENT_PRAYER="$PRAYER_NAME"
		notify-send --urgency=critical "Time for $PRAYER_NAME ($PRAYER_TIME)"
	elif [[ "$CURRENT_TIME" > "$PRAYER_TIME" ]]; then
		CURRENT_PRAYER="$PRAYER_NAME"
	elif [[ "$CURRENT_TIME" < "$PRAYER_TIME" ]]; then
		NEXT_PRAYER="$PRAYER_NAME"
		break
	fi
done < "$HOME/.config/prayerhistory/$CURRENT_DATE.txt"

if [[ -z "$CURRENT_PRAYER" ]]; then
	CURRENT_PRAYER="Qiyam"
fi

if [[ "$1" == "1" ]]; then
	printf "$CURRENT_PRAYER"
else
	cat "$HOME/.config/prayerhistory/$CURRENT_DATE.txt"
	echo "Current prayer: $CURRENT_PRAYER"
	echo "Next prayer: $NEXT_PRAYER"
fi

