color=$(hyprpicker -a | grep '^#')
if [ -n "$color" ]; then
    notify-send "🎨 Color copiado" "<span fgcolor='$color'>$color</span>"
else
    notify-send "❌ No se seleccionó ningún color"
fi