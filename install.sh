set -euo pipefail

# Instalar programas necesarios
sudo pacman -S --needed --noconfirm cava
sudo pacman -S --needed --noconfirm dunst
sudo pacman -S --needed --noconfirm kitty
sudo pacman -S --needed --noconfirm rofi-wayland
sudo pacman -S --needed --noconfirm hyprpicker
sudo pacman -S --needed --noconfirm blueman
sudo pacman -S --needed --noconfirm pavucontrol
sudo pacman -S swaync
yay -S --noconfirm waypaper
yay -S --noconfirm hyprlock-git
yay -S --noconfirm wlogout
yay -S --noconfirm hyprshot


# Hyprland
echo "Aplicando configuraciones de Hypr..."
rm -rf "$HOME/.config/hypr"
ln -srv "./configs/hypr" "$HOME/.config/hypr"
hyprctl reload
echo "Listo"

# Waypaper
echo "Aplicando configuraciones de Waypaper..."
rm -rf "$HOME/.config/waypaper"
ln -srv "./configs/waypaper" "$HOME/.config/waypaper"
echo "Listo"

#Waybar
echo "Aplicando configuraciones de Waybar..."
rm -rf "$HOME/.config/waybar"
ln -srv "./configs/waybar" "$HOME/.config/waybar"
echo "Listo"

# Kitty
echo "Aplicando configuraciones de Kitty..."
rm -rf "$HOME/.config/kitty"
ln -srv "./configs/kitty" "$HOME/.config/kitty"
echo "Listo"

# Cava 
echo "Aplicando configuraciones de Cava..."
rm -rf "$HOME/.config/cava"
ln -srv "./configs/cava" "$HOME/.config/cava"
echo "Listo"

# rofi
echo "Aplicando configuraciones de rofi..."
rm -rf "$HOME/.config/rofi"
ln -srv "./configs/rofi" "$HOME/.config/rofi"
echo "Listo"

# wlogout
echo "Aplicando configuraciones de wlogout..."
rm -rf "$HOME/.config/wlogout"
ln -srv "./configs/wlogout" "$HOME/.config/wlogout"
echo "Listo"

# Cambiamos Fondo de Pantalla
swww-daemon &
swww img $DOTFILES_DIR/configs/wallpaper.jpg
hellwal -i $DOTFILES_DIR/configs/wallpaper.jpg --neon-mode --bright-offset 1 && pkill -USR2 waybar & pywalfox update &