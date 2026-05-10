#!/bin/bash
set -euo pipefail

# --- Variables y Funciones ---
DOTFILES_DIR=$(pwd)

log() { echo -e "\e[1;34m[INFO]\e[0m $1"; }
ok()  { echo -e "\e[1;32m[ OK ]\e[0m $1\n"; }

echo "============================================="
echo "  SCRIPT DE INSTALACIÓN HYPRLAND (ARCH)    "
echo "============================================="

# --- 0. YAY (BASE) ---
if ! command -v yay &>/dev/null; then
  log "Instalando yay..."
  sudo pacman -S --needed --noconfirm git base-devel
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd ..
  rm -rf yay
else
  log "yay ya está instalado."
fi

# --- 1. Instalación de Quickshell --- 
log "Instalando Quickshell..."
yay -S --noconfirm quickshell-overview-git

# --- 2. FUENTES (BASE) ---
log "Instalando fuentes base..."
sudo pacman -S --needed --noconfirm \
  ttf-dejavu ttf-liberation ttf-font-awesome ttf-nerd-fonts-symbols \
  noto-fonts-emoji

log "Instalando fuentes de AUR..."
yay -S --noconfirm \
    ttf-martian-mono ttf-hack-nerd \
    ttf-jetbrains-mono-nerd ttf-firacode-nerd

sudo fc-cache -fv
ok "Fuentes instaladas."

# --- 3. PAQUETES GENERALES (BASE) ---
log "Instalando paquetes base de Pacman..."
sudo pacman -S --needed --noconfirm \
    cava hyprpicker pavucontrol superfile \
    nautilus kcalc btop fastfetch obsidian \
    swaync discord unzip firefox zoxide \
    easyeffects vlc

log "Instalando paquetes base de AUR..."
yay -S --noconfirm clipse waypaper hyprshot \
    onlyoffice-bin pcloud-drive nwg-displays \
    vscodium-bin pokemon-colorscripts-git vesktop \
    insomnia-bin protonup-qt iriunwebcam-bin obs-studio

# --- 4. CONFIGURACIONES (DOTFILES) ---
log "Copiando configuraciones iniciales..."

# Hyprland
log "Aplicando configuraciones de Hyprland..."
rm -rf "$HOME/.config/hypr"
ln -srv "$DOTFILES_DIR/config/hypr" "$HOME/.config/hypr"
ok "Listo"

# Cava
log "Aplicando configuraciones de Cava..."
rm -rf "$HOME/.config/cava"
ln -srv "$DOTFILES_DIR/config/cava" "$HOME/.config/cava"
ok "Listo"

# Kitty
log "Aplicando configuraciones de Kitty..."
rm -rf "$HOME/.config/kitty"
ln -srv "$DOTFILES_DIR/config/kitty" "$HOME/.config/kitty"
ok "Listo"

# --- 5. Instalacion de Apps para juegos ---
log "Instalando apps de juegos..."
sudo pacman -S --needed --noconfirm steam
yay -S --noconfirm heroic-games-launcher-bin rpcs3-bin

# --- 6. INSTALACION DE OH MY ZSH ---
log "Instalando Oh My Zsh..."
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# --- 7. CONFIGURACIÓN VISUAL (HYPRLAND) ---
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    log "Detectado Hyprland activo. Aplicando cursores..."
    yay -S --noconfirm rose-pine-hyprcursor
    hyprctl setcursor rose-pine-hyprcursor 32
    hyprctl reload
else
    log "Hyprland no está activo (TTY). Se instalará el cursor pero no se aplicará ahora."
    yay -S --noconfirm rose-pine-hyprcursor
fi

echo "============================================="
echo "      INSTALACIÓN FINALIZADA CON ÉXITO       "
echo "============================================="
echo "Recomendación: Reinicia tu equipo para asegurar que todos los servicios carguen."