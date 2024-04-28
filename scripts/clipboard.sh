#!/bin/bash

HISTFILE="$HOME/.clipboard_history"
PREV_CLIPBOARD=$(xclip -o -selection clipboard)

while sleep 1; do
	CURRENT_CLIPBOARD=$(xclip -o -selection clipboard)
	
	if [[ "$CURRENT_CLIPBOARD" != "$PREV_CLIPBOARD" ]]; then
		if [[ ! -s $HISTFILE ]]; then
			echo "$CURRENT_CLIPBOARD" > $HISTFILE
		else
			sed -i "1i $CURRENT_CLIPBOARD" $HISTFILE
		fi
		
		if [[ $(wc -l $HISTFILE) > 10 ]] then sed -i "11d" $HISTFILE; fi
	fi
	
	PREV_CLIPBOARD=$CURRENT_CLIPBOARD
done

