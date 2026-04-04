#/bin/bash

package_manager="$(for cmd in apt dnf apk pacman zypper; do
command -v $cmd &>/dev/null && echo $cmd && break
done)"

if [ "$package_manager" != "apt" ] && [ "$package_manager" != "zypper" ] && [ "$package_manager" != "dnf" ] && [ "$package_manager" != "pacman" ] && [ "$package_manager" != "apk" ]; then

echo " ✕ Unsupported package manager '$package_manager'.

Program cannot continue, exiting."

exit

else

sleep .1

fi

tool_to_pkg_name() {
case "$1" in
"7z") echo "7zip" ;;
#"7z")  echo "p7zip-full" ;;
"dig")  echo "dnsutils" ;;
"sha256sum")  echo "coreutils" ;;
"xdg-open")  echo "xdg-utils" ;;
"chsh")  echo "shadow" ;;
"tput")  echo "ncurses" ;;
*)     echo "$1" ;;
esac
}

#

check_programs() {
declare -g missing=()

# Mid script runtime
if [ "$package_manager" == "apk" ]; then
pkgmngr_install="$package_manager add"
pkgmngr_refresh="$package_manager update"

# Read the VERSION_ID line and extract the version
version=$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | cut -d. -f1,2)

# Set alpineversion variable
alpineversion=$version

# Use it in your URL
echo "http://dl-cdn.alpinelinux.org/alpine/v$alpineversion/community" | tee -a /etc/apk/repositories
apk update

cat > /etc/init.d/fuse << 'EOF'
#!/sbin/openrc-run
name="fuse"
description="Load FUSE kernel module"
command="modprobe"
command_args="fuse"
command_background="no"
pidfile="/run/fuse.pid"
depend() {
    need localmount
}
EOF

chmod +x /etc/init.d/fuse

rc-update add fuse default
rc-service fuse start

local programs=("sudo" "chsh" "fuse" "gcompat" "engrampa")  # Add more here
fi

if [ "$package_manager" == "dnf" ]; then
local programs=("fuse-libs" "fuse")  # Add more here
fi

if [ "$package_manager" == "apt" ]; then
pkgmngr_install="sudo $package_manager install -y"
pkgmngr_refresh="sudo $package_manager update"
local programs=("fuse-libs" "fuse")  # Add more here
fi

if [ "$package_manager" == "dnf" ]; then
pkgmngr_install="sudo $package_manager install -y"
pkgmngr_refresh="sudo $package_manager makecache"
local programs=("fuse-libs" "fuse")  # Add more here
fi

if [ "$package_manager" == "pacman" ]; then
pkgmngr_install="sudo pacman -Syu --noconfirm"
pkgmngr_refresh="sleep .1"
local programs=("fuse-libs" "fuse")  # Add more here
fi

if [ "$package_manager" == "zypper" ]; then
pkgmngr_install="sudo $package_manager install -y"
pkgmngr_refresh="sudo $package_manager refresh"
local programs=("fuse-libs" "fuse")  # Add more here
fi


for prog in "${programs[@]}"; do
if ! command -v "$prog" &>/dev/null; then

    echo -e " ✕ $prog is not installed" | if [ "$tui_flag" = "1" ]; then
        cat
    fi

    missing+=("$(tool_to_pkg_name "$prog")")
    #missing+=("$prog")

else

    echo -e " ✓ $prog is installed" | if [ "$tui_flag" = "1" ]; then
        cat
    fi

fi
done

echo "
Attempting to install package(s):
'${missing[*]}'
"

printf " 🔐 " ; $pkgmngr_refresh ; $pkgmngr_install ${missing[*]}


# End script runtime
if [ "$package_manager" == "apk" ]; then
# runs Alpine Linux Desktop Setup Tool
setup-desktop

echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel
chmod 0440 /etc/sudoers.d/wheel

getusername=$(getent passwd 1000 | cut -d: -f1)

# Adds user to sudo group
adduser $getusername wheel


# Changes current user + root's terminal interpreter to bash
chsh -s /bin/bash root
chsh -s /bin/bash $getusername

# Wakes up FUSE
#modprobe fuse
fi


if [ "$package_manager" == "dnf" ]; then
continue
fi


if [ "$package_manager" == "apt" ]; then
continue
fi


if [ "$package_manager" == "dnf" ]; then
continue
fi


if [ "$package_manager" == "pacman" ]; then
continue
fi


if [ "$package_manager" == "zypper" ]; then
continue
fi

}

check_programs

#apk add bash curl ; curl -fsS https://raw.githubusercontent.com/jcore92/MutagenesisX/main/install_fuse_tools.sh -o install_fuse_tools.sh ; bash install_fuse_tools.sh
