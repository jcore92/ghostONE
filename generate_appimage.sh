#!/bin/bash
chmod +x ./appimagetool-x86_64.AppImage
chmod -R +x ./MutagenesisX.AppDir

if x-terminal-emulator -e bash -c "ARCH=x86_64 ./appimagetool-x86_64.AppImage ./MutagenesisX.AppDir ; read -p ''"; then
sleep .1
else
# List of terminal emulators with their -e syntax
terminals=(
"xfce4-terminal -x"           # XFCE
"konsole --execute"           # KDE
"mate-terminal -x"            # MATE
"kitty --execute"             # Kitty
"gnome-terminal --"           # GNOME
"lxterminal -e"               # LXDE
"tilix -e"                    # Tilix (VTE-based)
"alacritty --command"         # Alacritty
"urxvt -e"                    # RXVT
"terminator -e"               # Terminator
"deepin-terminal -e"          # Deepin
"wezterm start --"            # WezTerm
"xterm -e"                    # XTerm
)

for term in "${terminals[@]}"; do
cmd=($term)  # Split into command and args
if command -v "${cmd[0]}" &>/dev/null; then
    "${cmd[@]}" bash -c "ARCH=x86_64 ./appimagetool-x86_64.AppImage ./MutagenesisX.AppDir ; read -p ''"
    break # Exit the loop after the first successful command
fi
done

echo "No terminal emulator found. Please install xterm, gnome-terminal, or similar."
#exit 1
fi

# exec bash
exit
