#!/bin/bash

# Función para conectar a redes WiFi protegidas
wifi_connect() {
    SSID="$1"
    
    # Verificar si la red requiere contraseña
    security=$(nmcli -g SECURITY dev wifi list | grep -F "$SSID" | head -1 | cut -d: -f2)
    
    if [[ "$security" == "--" ]]; then
        # Red abierta (sin contraseña)
        nmcli device wifi connect "$SSID"
    else
        # Pedir contraseña con rofi
        PASSWORD=$(rofi -dmenu -p "Contraseña para $SSID" -password -lines 0)
        
        if [ -n "$PASSWORD" ]; then
            # Intentar conectar con contraseña
            nmcli device wifi connect "$SSID" password "$PASSWORD"
        else
            notify-send "Error WiFi" "Contraseña requerida"
        fi
    fi
}

# Función principal para listar redes
wifi_menu() {
    # Obtener lista de redes
    networks=$(nmcli -t -f SSID,SECURITY,IN-USE dev wifi list | sort -u)
    
    # Formatear para rofi
    options=()
    while IFS= read -r net; do
        ssid=$(echo "$net" | cut -d':' -f1)
        security=$(echo "$net" | cut -d':' -f2)
        status=$(echo "$net" | cut -d':' -f3)
        
        if [ "$status" == "*" ]; then
            options+=("✓ $ssid ($security)")
        else
            options+=("  $ssid ($security)")
        fi
    done <<< "$networks"
    
    # Mostrar menú con rofi
    selected=$(printf '%s\n' "${options[@]}" | rofi -dmenu -p "Redes WiFi" -no-custom)
    
    if [ -n "$selected" ]; then
        # Extraer SSID de la selección
        SSID=$(echo "$selected" | sed -E 's/^[✓ ]*//' | cut -d' ' -f1)
        wifi_connect "$SSID"
    fi
}

# Función para encender/apagar WiFi
toggle_wifi() {
    wifi_state=$(nmcli radio wifi)
    if [ "$wifi_state" = "enabled" ]; then
        nmcli radio wifi off
        notify-send "WiFi" "Desactivado"
    else
        nmcli radio wifi on
        notify-send "WiFi" "Activado"
        sleep 2
        wifi_menu
    fi
}

# Menú principal
option=$(echo -e "Conectarse a una red WiFi\nDesconectar WiFi\nEncender/Apagar WiFi" | rofi -dmenu -p "Opciones de red")

case "$option" in
    "Conectarse a una red WiFi") wifi_menu ;;
    "Desconectar WiFi") 
        nmcli device disconnect wlp3s0
        notify-send "WiFi" "Desconectado"
        ;;
    "Encender/Apagar WiFi") toggle_wifi ;;
esac