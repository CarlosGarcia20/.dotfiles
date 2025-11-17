#!/bin/bash
set -euo pipefail

# Determinar directorio del script
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Script de instalación del entorno de escritorio Hyprland"
echo "Instalando fuentes..."

sudo pacman -S --needed --noconfirm \
  ttf-dejavu ttf-liberation ttf-font-awesome ttf-nerd-fonts-symbols \
  noto-fonts-emoji ttf-jetbrains-mono-nerd ttf-fira-code

sudo fc-cache -fv
echo "Fuentes instaladas."

# Instalar yay si no existe
if ! command -v yay &>/dev/null; then
  echo "Instalando yay..."
  sudo pacman -S --needed --noconfirm git base-devel
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd ..
  rm -rf yay
else
  echo "yay ya está instalado."
fi

# Función para entorno de escritorio
desktop_configuration() {
  echo "Iniciando instalación para Desktop Hyprland..."

  echo "Instalando temas y cursores..."
  yay -S --noconfirm rose-pine-hyprcursor
  hyprctl setcursor rose-pine-hyprcursor 32

  echo "Instalando dependencias..."
  sudo pacman -S --needed --noconfirm \
    kitty cava rofi-wayland hyprpicker pavucontrol obsidian swaync nautilus \
    kcalc superfile discord btop fastfetch swww

  yay -S --noconfirm clipse waypaper hyprshot swayosd-git onlyoffice-bin pcloud-drive

  echo "Aplicando configuraciones..."
  for config in cava hypr kitty rofi swaync waybar waypaper wlogout; do
    rm -rf "$HOME/.config/$config"
    ln -srv "$DOTFILES_DIR/configs/$config" "$HOME/.config/$config"
  done

  echo "Cambiando fondo de pantalla..."
  swww-daemon &
  swww img "$DOTFILES_DIR/wallpapers/1004017.png"
  hellwal -i "$DOTFILES_DIR/wallpapers/1004017.png" --neon-mode --bright-offset 1 && \
  pkill -USR2 waybar & pywalfox update &

  echo "Activando notificaciones de volumen/brillo..."
  sudo systemctl enable --now swayosd-libinput-backend.service
  swayosd-server &

  echo "Configuración de escritorio Hyprland completa."
}

# Función para laptop
laptop_configuration() {
  echo "Iniciando instalación para Laptop Hyprland..."

  # Instalar cursor
  yay -S --noconfirm rose-pine-hyprcursor
  hyprctl setcursor rose-pine-hyprcursor 32

  # Recordatorio para multilib (necesario para Steam)
  echo "--------------------------------------------------------------------"
  echo "IMPORTANTE: Asegúrate de tener el repositorio [multilib] habilitado"
  echo "en tu /etc/pacman.conf para poder instalar Steam."
  echo "Presiona Enter para continuar..."
  echo "--------------------------------------------------------------------"
  read -r

  echo "Instalando paquetes de Pacman (oficiales)..."
  sudo pacman -S --needed --noconfirm \
    cava kitty rofi-wayland hyprpicker blueman pavucontrol obsidian swaync \
    nautilus kcalc superfile btop fastfetch discord \
    cups cups-pdf print-manager sane-airscan simple-scan \
    cheese steam nodejs pnpm code

  echo "Instalando paquetes de AUR (yay)..."
  yay -S --noconfirm \
    clipse waypaper hyprshot swayosd-git pcloud-drive \
    heroic-games-launcher-bin insomnia fnm nwg-displays navicat-premium

  echo "Habilitando servicio de impresión (CUPS)..."
  sudo systemctl enable --now cups.service

  echo "Aplicando configuraciones..."
  for config in cava hypr kitty rofi swaync waybar waypaper wlogout; do
    rm -rf "$HOME/.config/$config"
    ln -srv "$DOTFILES_DIR/configs/$config" "$HOME/.config/$config"
  done

  echo "Activando notificaciones de volumen/brillo..."
  sudo systemctl enable --now swayosd-libinput-backend.service
  swayosd-server &

  echo "Configurando fondo de pantalla..."
  swww-daemon &
  swww img "$DOTFILES_DIR/configs/wallpaper.jpg"
  hellwal -i "$DOTFILES_DIR/configs/wallpaper.jpg" --neon-mode --bright-offset 1 && \
  pkill -USR2 waybar & pywalfox update &

  echo "Configuración de laptop Hyprland completa."
}

# Menú
echo "¿Para qué sistema es este script?"
echo "1) Desktop"
echo "2) Laptop"
read -rp "Selecciona una opción (1 o 2): " choice

case $choice in
  1) desktop_configuration ;;
  2) laptop_configuration ;;
  *) echo "Opción inválida." ;;
esac