#!/bin/bash
set -euo pipefail

# --- VARIABLES Y RUTAS ---
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIGS_SRC="$DOTFILES_DIR/config" 

# --- FUNCIÓN PARA PREGUNTAR (S/n) ---
preguntar() {
    local mensaje="$1"
    read -rp "$mensaje [S/n]: " response
    case "${response,,}" in
        s|y|""|"si"|"yes") 
            return 0 ;; # 0 significa Verdadero (Sí)
        *) 
            return 1 ;; # 1 significa Falso (No)
    esac
}

echo "============================================="
echo "  SCRIPT DE INSTALACIÓN HYPRLAND (ARCH)    "
echo "============================================="

# --- 1. FUENTES (BASE) ---
echo ">> Instalando fuentes..."
sudo pacman -S --needed --noconfirm \
  ttf-dejavu ttf-liberation ttf-font-awesome ttf-nerd-fonts-symbols \
  noto-fonts-emoji ttf-jetbrains-mono-nerd ttf-fira-code
sudo fc-cache -fv
echo "Fuentes instaladas."

# --- 2. YAY (BASE) ---
if ! command -v yay &>/dev/null; then
  echo ">> Instalando yay..."
  sudo pacman -S --needed --noconfirm git base-devel
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd ..
  rm -rf yay
else
  echo "yay ya está instalado."
fi

# --- 3. PAQUETES GENERALES (BASE) ---
echo ">> Instalando paquetes base de Pacman..."
sudo pacman -S --needed --noconfirm \
    cava rofi-wayland hyprpicker pavucontrol superfile \
    nautilus kcalc btop fastfetch swww \
    obsidian swaync discord unzip

echo ">> Instalando paquetes base de AUR..."
yay -S --noconfirm clipse waypaper hyprshot \
    onlyoffice-bin pcloud-drive navicat17-premium-en \
    nwg-displays

# --- 4. CONFIGURACIONES (DOTFILES) ---
echo ">> Copiando configuraciones iniciales..."

for app in cava kitty rofi swaync waybar wlogout hypr; do
    echo "Vinculando $app..."
    rm -rf "$HOME/.config/$app"
    ln -srv "$CONFIGS_SRC/$app" "$HOME/.config/$app"
done

echo "Configuraciones copiadas."

# --- 5. CONFIGURACIÓN VISUAL (HYPRLAND) ---
# Solo ejecutamos esto si Hyprland está corriendo para evitar errores
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    echo ">> Detectado Hyprland activo. Aplicando cursores..."
    yay -S --noconfirm rose-pine-hyprcursor
    hyprctl setcursor rose-pine-hyprcursor 32
    hyprctl reload
else
    echo ">> Hyprland no está activo (TTY). Se instalará el cursor pero no se aplicará ahora."
    yay -S --noconfirm rose-pine-hyprcursor
fi


# ==========================================
#           SECCIÓN INTERACTIVA
# ==========================================

# --- FUNCIÓN: LAPTOP ---
laptop_paqueteria() {
    echo ">> Instalando paquetes para Laptop..."
    sudo pacman -S --needed --noconfirm \
        cups cups-pdf print-manager \
        sane-airscan simple-scan cheese

    echo "Habilitando servicio de impresión (CUPS)..."
    sudo systemctl enable --now cups.service
    echo "Paquetes de Laptop instalados."
}

if preguntar "¿Deseas instalar la paquetería para LAPTOP (impresoras, cámara, scanner)?"; then
    laptop_paqueteria
else
    echo "Saltando configuración de laptop."
fi


# --- FUNCIÓN: NOTIFICACIONES OSD ---
servicio_notificaciones() {
    echo ">> Instalando demonio OSD (Volumen/Brillo)..."
    yay -S --noconfirm swayosd-git
    sudo systemctl enable --now swayosd-libinput-backend.service
    
    if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        swayosd-server &
    fi
    echo "OSD Instalado."
}

if preguntar "¿Deseas instalar el servicio de notificaciones OSD?"; then
    servicio_notificaciones
else
    echo "Saltando notificaciones OSD."
fi


# --- FUNCIÓN: JUEGOS ---
aplicaciones_juegos() {
    echo ">> Instalando Juegos..."
    
    # Recordatorio Multilib
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        echo "/!\ ADVERTENCIA: Asegúrate de tener [multilib] habilitado en /etc/pacman.conf para Steam."
        sleep 2
    fi

    sudo pacman -S --needed --noconfirm steam
    yay -S --noconfirm heroic-games-launcher-bin 
    echo "Juegos instalados."
}

if preguntar "¿Deseas instalar la suite de JUEGOS (Steam, Heroic)?"; then
    aplicaciones_juegos
else
    echo "Saltando juegos."
fi


# --- FUNCIÓN: TEMAS GTK ---
temas_gtk() {
    echo ">> Instalando nwg-look y temas GTK..."
    # Instalamos nwg-look (Gestor) y un tema popular (Catppuccin)
    sudo pacman -S --needed --noconfirm nwg-look
    yay -S --noconfirm catppuccin-gtk-theme-mocha
    
    echo "Instalado. Abre 'nwg-look' para aplicar el tema cuando termines."
}

if preguntar "¿Deseas instalar herramientas de TEMAS GTK (nwg-look)?"; then
    temas_gtk
else
    echo "Saltando temas GTK."
fi


echo "============================================="
echo "      INSTALACIÓN FINALIZADA CON ÉXITO       "
echo "============================================="
echo "Recomendación: Reinicia tu equipo para asegurar que todos los servicios carguen."