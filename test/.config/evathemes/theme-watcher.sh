#!/bin/bash

LOGFILE="$HOME/.config/evathemes/theme-watcher.log"

while true; do
    # Time check
    HOUR=$(date +%H)

    if (( 7 <= HOUR && HOUR < 19 )); then
        THEME="nerv"
        WALLPAPER="$HOME/.config/backgrounds/NERV.jpg"
    else
        THEME="seele"
        WALLPAPER="$HOME/.config/backgrounds/SEELE.jpg"
    fi

    # Theme switching
    echo "$(date): Switching to theme $THEME" >> "$LOGFILE"
    ~/.config/evathemes/eva-theme-switcher.sh "$THEME" >> "$LOGFILE" 2>&1

    # Wallpaper switch (only if different)
    CURRENT_WALL=$(hyprctl getoption decoration:wallpaper | grep 'str:' | awk -F'"' '{print $2}')
    if [[ "$CURRENT_WALL" != "$WALLPAPER" ]]; then
        hyprctl hyprpaper unload all
        hyprctl hyprpaper preload "$WALLPAPER"
        hyprctl hyprpaper wallpaper "eDP-1,$WALLPAPER"
    fi

    sleep 10
done
