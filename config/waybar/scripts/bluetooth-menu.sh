#!/bin/bash

# Función para encender/apagar Bluetooth
toggle_bluetooth() {
    if [[ $(bluetoothctl show | grep "Powered: yes") ]]; then
        bluetoothctl power off
        notify-send "Bluetooth" "Desactivado"
    else
        bluetoothctl power on
        notify-send "Bluetooth" "Activado"
    fi
}

# Función para listar dispositivos y conectarse
connect_bluetooth() {
    devices=$(bluetoothctl devices | awk '{print $3 " " $2}')
    selected_device=$(echo "$devices" | rofi -dmenu -p "Dispositivos Bluetooth" | awk '{print $2}')
    
    if [[ -n "$selected_device" ]]; then
        bluetoothctl connect "$selected_device"
        notify-send "Bluetooth" "Conectando a $selected_device"
    fi
}

# Función para desconectar
disconnect_bluetooth() {
    connected_device=$(bluetoothctl info | grep "Device" | awk '{print $2}')
    if [[ -n "$connected_device" ]]; then
        bluetoothctl disconnect "$connected_device"
        notify-send "Bluetooth" "Desconectado"
    else
        notify-send "Bluetooth" "Ningún dispositivo conectado"
    fi
}

# Menú principal
option=$(echo -e "1. Encender/Apagar Bluetooth\n2. Conectar dispositivo\n3. Desconectar dispositivo" | rofi -dmenu -p "Opciones Bluetooth")
case "$option" in
    "1. Encender/Apagar Bluetooth") toggle_bluetooth ;;
    "2. Conectar dispositivo") connect_bluetooth ;;
    "3. Desconectar dispositivo") disconnect_bluetooth ;;
esac