#!/bin/bash

CITY=""
COUNTRY=""

CURRENT_TIME=$(date +"%H:%M")
TIMINGS=$(curl -Ls "http://api.aladhan.com/v1/timingsByCity?city=$CITY&country=$COUNTRY&method=4&adjustment=1" | jq ".data.timings" | sed "1d;3d;6d;9,13d")

echo "$TIMINGS"

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
done < <(echo "$TIMINGS")

echo "Current prayer: $CURRENT_PRAYER"
echo "Next prayer: $NEXT_PRAYER"
