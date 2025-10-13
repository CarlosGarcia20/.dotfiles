#!/bin/bash
battery=$(cat /sys/class/power_supply/BAT1/capacity)
status=$(cat /sys/class/power_supply/BAT1/status)

# Iconos según estado (nerd fonts)
[ "$status" = "Charging" ] && icon="" || icon=""

# Color según porcentaje
if [ $battery -ge 80 ]; then
    color="#a6e3a1"  # Verde
elif [ $battery -ge 30 ]; then
    color="#f9e2af"  # Amarillo
else
    color="#f38ba8"  # Rojo
fi

echo "<span foreground='$color'>$icon $battery%</span>"