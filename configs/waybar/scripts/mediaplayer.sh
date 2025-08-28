#!/bin/bash

player_status=$(playerctl status 2>/dev/null)

if [ "$player_status" = "Playing" ] || [ "$player_status" = "Paused" ]; then
    artist=$(playerctl metadata artist | cut -c1-20)
    title=$(playerctl metadata title | cut -c1-30)
    
    if [ "$player_status" = "Playing" ]; then
        icon=""
    else
        icon=""
    fi
    
    # Asegúrate de usar "text" como clave
    echo "{\"text\":\"$artist - $title\",\"icon\":\"$icon\",\"class\":\"$player_status\"}"
else
    echo "{}"
fi