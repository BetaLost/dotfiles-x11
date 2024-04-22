#!/bin/bash

CITY="Sharjah"
COUNTRY="AE"

CURRENT_TIME=$(date +"%H:%M")
CURRENT_DATE=$(date +"%d-%m-%Y")

if [[ ! -f "$HOME/.config/prayerhistory/$CURRENT_DATE.txt" ]]; then
	TIMINGS=$(curl -Ls "http://api.aladhan.com/v1/timingsByCity?city=$CITY&country=$COUNTRY&method=4&adjustment=1" | jq ".data.timings" | sed "1d;6d;9,13d")
	echo "$TIMINGS" > "$HOME/.config/prayerhistory/$CURRENT_DATE.txt"
fi

duration() {
	time_diff=$(($(date -d "$2" +%s) - $(date -d "$1" +%s)))
	hours=$((time_diff / 3600))
	minutes=$(((time_diff % 3600) / 60))
	
	printf '%02d:%02d\n' "$hours" "$minutes"
}

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
		NEXT_PRAYER_TIME="$PRAYER_TIME"
		break
	fi
done < "$HOME/.config/prayerhistory/$CURRENT_DATE.txt"


if [[ -z "$CURRENT_PRAYER" ]]; then
	CURRENT_PRAYER="Qiyam"
fi

if [[ "$1" == "1" ]]; then
	if [[ -n "$NEXT_PRAYER" ]]; then
		TIME_REMAINING=$(duration $CURRENT_TIME $NEXT_PRAYER_TIME)
		printf "$CURRENT_PRAYER ($TIME_REMAINING to $NEXT_PRAYER)"
	else
		printf "$CURRENT_PRAYER"
	fi
else
	cat "$HOME/.config/prayerhistory/$CURRENT_DATE.txt"
	echo "Current prayer: $CURRENT_PRAYER"
	
	if [[ -n "$NEXT_PRAYER" ]]; then
		TIME_REMAINING=$(duration $CURRENT_TIME $NEXT_PRAYER_TIME)
		echo "Next prayer: $NEXT_PRAYER in $TIME_REMAINING"
	else
		echo "Next prayer: $NEXT_PRAYER"
	fi
fi

