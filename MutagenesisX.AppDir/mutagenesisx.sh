#!/bin/bash

mutagenesisx-shell () {

    # =============================================================================
    # SECTION: System Environment Variables
    # =============================================================================

    # APPLICATION INFORMATION

    app_name="MutagenesisX"
    file_name="mutagenesisx.sh"

    app_ver_major="1"
    app_ver_minor="0"
    app_ver_build="0"
    app_ver_stage="beta"
    probe_name="xProbe"

    gui_flag="0"
    tui_flag="0"

    # LOCATIONS

    app_temp_loc="/tmp/$app_name"

    # SYSTEM INFORMATION

    current_user="$whoami"

    package_manager="$(for cmd in apt dnf apk pacman zypper; do
    command -v $cmd &>/dev/null && echo $cmd && break
    done)"

    if [ "$package_manager" == "apt" ]; then
    pkgmngr_install="sudo $package_manager install -y"
    pkgmngr_refresh="sudo $package_manager update"
    fi

    if [ "$package_manager" == "dnf" ]; then
    pkgmngr_install="sudo $package_manager install -y"
    pkgmngr_refresh="sudo $package_manager makecache"
    fi

    if [ "$package_manager" == "apk" ]; then
    pkgmngr_install="sudo $package_manager add"
    pkgmngr_refresh="sudo $package_manager update"
    fi

    if [ "$package_manager" == "pacman" ]; then
    pkgmngr_install="sudo pacman -Syu --noconfirm"
    pkgmngr_refresh="sleep .1"
    fi

    if [ "$package_manager" == "zypper" ]; then
    pkgmngr_install="sudo $package_manager install -y"
    pkgmngr_refresh="sudo $package_manager refresh"
    fi

    # DEFAULT GUI WINDOW SIZES THEN OVERRIDES BASED ON DE:

    default_eula_gui_dimensions="--width=550 --height=550"
    default_mainmenu_gui_dimensions="--width=450 --height=550"
    default_loading_gui_dimensions="--width=300 --height=200"
    default_messagebox_gui_dimensions="--width=350"


    if [ "$XDG_CURRENT_DESKTOP" == "XFCE" ]; then

    default_eula_gui_dimensions="--width=450 --height=500"
    default_mainmenu_gui_dimensions="--width=400 --height=500"
    default_loading_gui_dimensions="--width=300 --height=200"
    default_messagebox_gui_dimensions="--width=350"

    fi

    if [ "$XDG_CURRENT_DESKTOP" == "COSMIC" ]; then

    default_eula_gui_dimensions="--width=550 --height=600"
    default_mainmenu_gui_dimensions="--width=450 --height=600"
    default_loading_gui_dimensions="--width=300 --height=200"
    default_messagebox_gui_dimensions="--width=350"

    fi

    if [ "$XDG_CURRENT_DESKTOP" == "KDE" ]; then

    default_eula_gui_dimensions="--width=500 --height=500"
    default_mainmenu_gui_dimensions="--width=400 --height=500"
    default_loading_gui_dimensions="--width=300 --height=200"
    default_messagebox_gui_dimensions="--width=350"

    fi

    if [[ "$XDG_CURRENT_DESKTOP" == *GNOME* ]]; then

    default_eula_gui_dimensions="--width=500 --height=500"
    default_mainmenu_gui_dimensions="--width=400 --height=500"
    default_loading_gui_dimensions="--width=300 --height=200"
    default_messagebox_gui_dimensions="--width=350"

    fi

    # =============================================================================
    # SECTION: Terminal Interface
    # =============================================================================

    center() {
        local width
        width="${COLUMNS:-$(tput cols)}"
        while IFS= read -r line; do
            # Strip color codes to get the actual text length
            local stripped_line=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g')
            local actual_length=${#stripped_line}

            if (( actual_length == width )); then
            printf '%s\n' "$line"
            continue
            fi

            if (( actual_length > width )); then
            while read -r subline; do
                local stripped_subline=$(echo "$subline" | sed 's/\x1b\[[0-9;]*m//g')
                local subline_length=${#stripped_subline}

                if (( subline_length == width )); then
                printf '%s\n' "$subline"
                continue
                fi
                printf '%*s\n' $(( (subline_length + width) / 2 )) "$subline"
            done < <(fold -w "$width" <<< "$line")
            continue
            fi

            printf '%*s\n' $(( (actual_length + width) / 2 )) "$line"
        done < "${1:-/dev/stdin}"
    }

    print_red() {
        while IFS= read -r line; do
        # Calculate the length of the original line
        local original_length=${#line}
        # Print the line in red, ensuring the length is preserved
        printf "\033[31m%s\033[0m\n" "$line"
        done
    }

    divider () {
        echo ""
        printf -- ".%.0s" $(seq $(tput cols))
        echo ""
    }

    cursor_menu() {
        local prompt="$1" outvar="$2" options=("${@:3}")
        local cur=0 count=${#options[@]}
        local esc=$(echo -en "\e")

        printf "$prompt\n"
        while true; do
        local index=0
        for o in "${options[@]}"; do
            if [ $index -eq $cur ]; then
                echo -e " >\e[7m$o\e[0m"
            else
                echo "  $o"
            fi
            ((index++))
        done

        read -s -n3 key
        case "$key" in
            "$esc[A") ((cur--)); ((cur < 0)) && cur=0 ;;
            "$esc[B") ((cur++)); ((cur >= count)) && cur=$((count - 1)) ;;
            "") break ;;
        esac
        echo -en "\e[${count}A"
        done

        printf -v "$outvar" "${options[$cur]}"
    }

    entertocontinue () {

        entertocontinue=(
        ""
        "Press enter to continue"
        )

        # Get the terminal width
        term_width=$(tput cols)

        # Function to center a line
        center_line() {
            local line="$1"
            local line_length=${#line}
            local padding=$(( (term_width - line_length) / 2 ))
            printf "%${padding}s%s%${padding}s\n" "" "$line" ""
        }

        # Center each line of the image
        for line in "${entertocontinue[@]}"; do
            center_line "$line"
        done

        read -p ""

    }

    text_delay () {

    sleep .1

    }

    jcorestudios_banner() {
            # The multi-line image
            logotitle=(
            ""
            ""
            "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
            "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
            "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
            "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
            "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⠏⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
            "⣿⣿⣿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⣿⣿⡟⣠⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
            "⣿⣯⠀⠀⠀⠀⠄⠉⠉⠉⠛⠻⢿⠋⣿⣿⣿⣿⣿⣿⢃⠀⣿⡿⢱⣿⣸⣿⣿⣿⣿⣿⡏⣿⣿⠛⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
            "⣿⣿⣧⡀⠀⠂⣾⣿⣿⣿⣶⣶⡆⣠⢸⣻⠿⠿⣿⡟⢸⠀⣿⢃⣾⣿⡏⣿⣿⣿⣿⣿⠀⢻⡏⡄⢡⡜⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
            "⣿⣿⣿⣿⠶⡄⠘⢿⣿⣿⣿⣿⢃⣿⢸⣿⡟⢳⣶⢁⣟⠀⢇⣾⣿⣿⡇⢻⣿⣿⠀⡟⢀⢸⢱⣧⣾⣿⡘⢛⣛⣛⣛⣛⣛⣻⣿⣿⣿⣿⣿"
            "⣿⣿⣿⣿⣶⣶⣶⣦⣐⢶⣶⣶⣾⣿⡏⡟⢸⡄⠇⣼⣿⠀⣰⣽⣿⡻⢷⢸⣿⡇⣤⠀⣿⠀⣾⣿⣿⣿⣿⣷⣽⡻⢿⣿⣿⣿⣿⣿⣿⣿⣿"
            "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣿⣿⣿⣿⡇⢠⣿⣿⣴⣿⣿⣷⣿⣿⣿⣿⣷⡄⣟⢀⢿⣾⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣦⠙⠻⣿⣿⣿⣿⣿⣿"
            "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠃⣼⣿⣶⣭⣙⡛⠿⠿⢿⣿⣿⣿⣿⣿⣷⠀⠈⠻⣿⣿⣿⣿"
            "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⢠⣿⣿⣿⣿⣿⣿⣷⣶⣤⣄⣈⡉⠉⠉⠀⠀⠀⠀⠈⣿⣿⣿"
            "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣶⣤⣴⣾⣿⣿⣿"
            "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
            "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
            "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
            "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
            ""
            )

            # Get the terminal width
            term_width=$(tput cols)

            # Function to center a line
            center_line() {
                local line="$1"
                local line_length=${#line}
                local padding=$(( (term_width - line_length) / 2 ))
                printf "%${padding}s%s%${padding}s\n" "" "$line" ""
            }

            # Center each line of the image
            for line in "${logotitle[@]}"; do
                center_line "$line"
            done

    }

    jcore92_banner() {
        # The multi-line image
        logotitle=(
        ""
        ""
        ""
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣔⣀⣄⣶⠟⢲⣶⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠴⣶⣶⣶⣶⡀⢀⠆⠰⡏⣿⠟⢀⣶⡿⢁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣤⣤⣼⣿⣿⣿⣿⢻⠃⠈⣾⣷⣤⡃⠀⣘⣩⣴⠸⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣏⡄⢠⠘⠻⠿⣿⣿⣿⣿⣿⣿⣇⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⡿⢿⣿⡿⡿⠷⠀⣄⡀⠀⠀⣿⠁⠀⠀⠈⢡⠖⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠙⠛⠛⠀⣄⡀⠀⠘⣲⠶⠿⣿⣷⣴⣤⠄⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⣠⡆⣶⡟⣠⡄⠀⠻⣧⣄⣐⣨⢭⠖⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠰⢶⡘⠄⢿⣇⠸⠆⠻⠅⣤⠀⣘⠲⠶⠋⠀⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⣮⢳⡄⠛⠋⠁⢰⡇⢀⡁⢠⢿⣿⠇⠀⣐⠈⡉⢠⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⠿⠋⠋⠀⠀⠀⠀⠀⠀⢀⣿⡯⢸⠟⠁⠘⠂⠘⠈⠃⡘⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⠟⢦⣀⠀⢀⠄⠒⠀⠀⠀⠈⠉⠀⠀⠀⠀⠀⣠⣄⢲⡀⢳⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠶⠶⠟⡀⢠⠀⠀⠀⠀⠀⠀⠀⠀⠀⢐⣴⠀⠹⣜⣦⠛⡛⣶⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠛⠋⠉⠀⠈⡀⠀⠀⠀⠆⣰⡆⣤⢰⣶⣅⣘⡗⠀⠁⠈⠻⢟⣛⠔⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠠⠀⠀⠀⠀⠀⠀⠀⠑⠂⢀⠀⣬⢇⡉⡘⠻⠆⣿⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠀⠀⠀⠀⠀⠀⠀⢀⡀⣸⠟⢼⢧⣿⣧⢠⣄⢠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠃⣿⡇⡆⣼⣿⠟⣞⡋⢀⠰⠶⠶⠶⠶⠶⠶⠶⠦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
        ""
        )

        # Get the terminal width
        term_width=$(tput cols)

        # Function to center a line
        center_line() {
            local line="$1"
            local line_length=${#line}
            local padding=$(( (term_width - line_length) / 2 ))
            printf "%${padding}s%s%${padding}s\n" "" "$line" ""
        }

        # Center each line of the image
        for line in "${logotitle[@]}"; do
            center_line "$line"
        done

    }

    mutagenesisx_banner() {
        # The multi-line image
        logotitle=(
        ""
        "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢿⣿⣿⣿⣿⣿⣿"
        "⣿⣿⣿⣟⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⠀⠀⡛⡛⢿⠋⠙⣿"
        "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠄⣴⡉⠉⠀⣰⣿"
        "⣿⣿⣿⣿⣿⣿⣼⣿⣛⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠧⠀⠈⠁⢀⣴⣿⣿"
        "⠛⡍⢡⣿⣿⣿⣏⣽⢻⢿⣮⡻⣿⣮⠛⣯⣿⣾⣿⠏⠀⠠⣶⡀⠬⢿⣿⣟"
        "⡘⢄⢣⣿⣿⣿⣿⣻⢿⣶⣝⢿⣿⣿⡑⢾⣿⣿⡏⠀⠸⠶⢶⠦⠀⣿⣿⣿"
        "⠰⣈⠲⣿⣿⣿⠛⡿⣿⣾⣙⢿⣿⣿⡐⣻⣿⣿⣧⠀⠸⣿⠗⠀⣸⣿⣿⣿"
        "⠱⢠⢙⣿⣿⣿⣠⢁⢸⣯⡻⢷⣿⣿⠰⣹⣿⣿⠿⠃⢀⠠⠐⢴⣿⣿⣿⣿"
        "⡑⢂⢎⣿⣿⣿⣿⣿⣾⣟⠿⣷⣿⣿⢡⢻⣿⠋⢠⣶⡻⠿⣄⠈⢿⣿⣿⣿"
        "⡘⢄⠊⢿⣿⢿⣿⣿⣿⣿⣿⣦⣿⣿⢂⢿⣯⣀⣽⣛⣛⡷⠶⠀⢸⣿⣿⣿"
        "⡐⢊⠜⡠⢂⠬⣁⠛⡛⢿⣿⣿⣿⣿⠌⣾⣿⣿⣿⣿⣿⣿⣿⣤⣾⣿⣿⣿"
        "⡘⠤⠚⡄⢃⡒⢄⠣⡘⠰⡈⠿⣿⣿⡘⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
        "⠐⠁⠁⠀⠀⠀⠀⠀⠀⠁⠈⠀⠉⠋⠐⠹⠛⠋⠉⠉⠉⠉⠉⠉⠉⠛⠻⠿"
        "⠀⠀⠀⢀⣀⣀⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀⣀⣀⣀⣀⣀⣀⣀⡀⠀⠀⠀"
        "⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶"
        ""
        )

        # Get the terminal width
        term_width=$(tput cols)

        # Function to center a line
        center_line() {
            local line="$1"
            local line_length=${#line}
            local padding=$(( (term_width - line_length) / 2 ))
            printf "%${padding}s%s%${padding}s\n" "" "$line" ""
        }

        # Center each line of the image
        for line in "${logotitle[@]}"; do
            center_line "$line"
        done

        sleep .2

    }

    credits () {

    if [ "$gui_flag" = "1" ]; then

    echo "$app_name $app_ver_major.$app_ver_minor.$app_ver_build $app_ver_stage
GPL-2.0 license

Presented By:
https://jcorestudios.com/
https://github.com/jcore92

Infused with MutagenesisX, ghostAPT v2, and Command Center's DNA. (Various older predecessor's of MutagenesisX.)

jcore92 - Lead Programmer" | zenity --text-info --title="About $app_name" $default_mainmenu_gui_dimensions #--ok-label="" --cancel-label="" &

    fi



    if [ "$tui_flag" = "1" ]; then

    clear

    jcorestudios_banner

    echo "Presented By:
https://jcorestudios.com/
https://github.com/jcore92" | center

    sleep 3

    clear

    jcore92_banner

    echo "$app_name $app_ver_major.$app_ver_minor.$app_ver_build $app_ver_stage" | center

    echo "GPL-2.0 license
" | center

    echo "Infused with MutagenesisX, ghostAPT v2, and Command Center's DNA.
(Various older predecessor's of MutagenesisX.)

jcore92 - Lead Programmer" | center

    sleep 3

    clear

    fi

    }

    eula_prompt () {

    if [ "$tui_flag" == "1" ]; then

        if cat $APPDIR/LICENSE | less; then
            # User clicked "I Agree"
            echo "User agreed to EULA."
            text_delay
            clear
        else
            # User canceled or closed
            exit 1
        fi

    fi

    if [ "$gui_flag" == "1" ]; then

        if zenity --text-info --title="$app_name: EULA" $default_eula_gui_dimensions --filename="$APPDIR/LICENSE" --ok-label="I Agree"; then
            # User clicked "I Agree"
            text_delay
        else
            # User canceled or closed
            exit 1
        fi

    fi


    }

    xprobe () {

        echo "$app_name $app_ver_major.$app_ver_minor.$app_ver_build $app_ver_stage" | center

        echo "$probe_name Report" | center

        divider

        echo ""

        # Initialize array
        xprob_messages=()

        #text_delay ; echo "Checking environment..."

        #if [ "$XDG_SESSION_TYPE" = "tty" ]; then

            #text_delay ; echo " ✕ TTY is not supported. Please use a Desktop Environment to open $app_name." | if [ "$gui_flag" = "1" ]; then
                #zenity --text-info $default_mainmenu_gui_dimensions
            #else
                #cat | print_red
            #fi

        #if [ "$tui_flag" = "1" ]; then
            #divider
            #entertocontinue
        #fi
        #exit
        #fi


        if [ -n "$WSL_DISTRO_NAME" ] || [ -n "$IS_WSL" ]; then

            text_delay ; echo " ✕ WSL is not supported." | if [ "$gui_flag" = "1" ]; then
                zenity --text-info $default_mainmenu_gui_dimensions
            else
                cat | print_red
                #entertocontinue
            fi

        if [ "$tui_flag" = "1" ]; then
            divider
            entertocontinue
        fi
        exit
        fi

        #text_delay ; echo "Checking package manager..."

        if [ "$package_manager" != "apt" ] && [ "$package_manager" != "zypper" ] && [ "$package_manager" != "dnf" ] && [ "$package_manager" != "pacman" ] && [ "$package_manager" != "apk" ]; then

            text_delay ; echo " ✕ Unsupported package manager '$package_manager'.

Program cannot continue, exiting." | if [ "$gui_flag" = "1" ]; then
                zenity --text-info $default_mainmenu_gui_dimensions --title="$app_name: $probe_name Report" --cancel-label=""
                #exit
            else
                cat | print_red
            fi

            if [ "$tui_flag" = "1" ]; then
            divider
            entertocontinue
            fi

            exit

        fi



        # Get system's pretty name to display
        prettyname="$(cat /etc/os-release | grep "PRETTY_NAME" | awk -F '"' '{print $2}')"

        # Check the /etc/os-release file for any trace of Ubuntu or Debian: ubuntu debian
        if grep -qi "ubuntu" /etc/os-release; then

            xprob_messages+=("$prettyname")
            xprob_messages+=(" ✓ package manager: $package_manager")
            xprob_messages+=(" ✓ distro-bridge: disabled")
            xprob_messages+=(" ✓ desktop env: $XDG_CURRENT_DESKTOP")

            text_delay ; echo "$prettyname" | if [ "$tui_flag" = "1" ]; then
                cat
            fi

            text_delay ; echo " ✓ package manager: $package_manager" | if [ "$tui_flag" = "1" ]; then
                cat
            fi

            if [ "$tui_flag" = "1" ]; then
            echo " ✓ distro-bridge: disabled"
            #divider
            #entertocontinue
            fi

            text_delay ; echo " ✓ desktop env: $XDG_CURRENT_DESKTOP" | if [ "$tui_flag" = "1" ]; then
                cat
            fi

        elif grep -qi "debian" /etc/os-release; then

            xprob_messages+=("$prettyname")
            xprob_messages+=(" ✓ package manager: $package_manager")
            xprob_messages+=(" ✓ distro-bridge: disabled")
            xprob_messages+=(" ✓ desktop env: $XDG_CURRENT_DESKTOP")

            text_delay ; echo "$prettyname" | if [ "$tui_flag" = "1" ]; then
                cat
            fi

            text_delay ; echo " ✓ package manager: $package_manager" | if [ "$tui_flag" = "1" ]; then
                cat
            fi

            if [ "$tui_flag" = "1" ]; then
            echo " ✓ distro-bridge: disabled"
            #divider
            #entertocontinue
            fi

            text_delay ; echo " ✓ desktop env: $XDG_CURRENT_DESKTOP" | if [ "$tui_flag" = "1" ]; then
                cat
            fi

        else

            if [ "$gui_flag" = "1" ]; then
            echo "# generating results..." >&3
            sleep 1
            echo "# displaying report..." >&3
            fi

            xprob_messages+=("$prettyname")
            xprob_messages+=(" ✓ package manager: $package_manager")
            xprob_messages+=(" ✓ distro-bridge: enabled")
            xprob_messages+=(" ✓ desktop env: $XDG_CURRENT_DESKTOP")

            text_delay ; echo "$prettyname" | if [ "$tui_flag" = "1" ]; then
                cat
            fi

            text_delay ; echo " ✕ Ubuntu or Debian base NOT installed

INFO:
***

We will try to enable the distro-bridge compatibility layer. (allows the use of other package managers outside of apt).

distro-bridge support: zypper, pacman, dnf, apk.

***" | if [ "$gui_flag" = "1" ]; then
                #zenity --text-info $default_mainmenu_gui_dimensions --title="$app_name: $probe_name Report" --cancel-label="" --timeout=10
                zenity --progress --pulsate --timeout=2 --text="Enabling distro-bridge for non-debian distros..." --title="$app_name: distro-bridge" $default_loading_gui_dimensions --no-cancel &
            else
                cat | print_red
            fi

            text_delay ; echo " ✓ package manager: $package_manager" | if [ "$tui_flag" = "1" ]; then
                cat
            fi

            if [ "$tui_flag" = "1" ]; then
            echo " ✓ distro-bridge: enabled"
            #divider
            #entertocontinue
            fi

            text_delay ; echo " ✓ desktop env: $XDG_CURRENT_DESKTOP" | if [ "$tui_flag" = "1" ]; then
                cat
            fi

            sleep .5
            #exit
        fi




        if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then

            text_delay ; echo " ✕ display server: wayland

WARNING:
***

wayland is incomplete and broken by design (not a true x11 drop-in replacement). For a more complete Linux experience consider a complete x11/xLibre solution instead.

***" | if [ "$gui_flag" = "1" ]; then
                zenity --text-info $default_mainmenu_gui_dimensions --title="$app_name: $probe_name Report" --cancel-label="" --timeout=10
            else
                cat | print_red
            fi

            if [ "$tui_flag" = "1" ]; then
            divider
            entertocontinue
            fi

            xprob_messages+=(" ✕ display server: wayland")
            #exit

            else

            xprob_messages+=(" ✓ display server: $XDG_SESSION_TYPE")

            text_delay ; echo " ✓ display server: $XDG_SESSION_TYPE" | if [ "$tui_flag" = "1" ]; then
                cat
            fi
            fi





        if [[ -d /run/systemd/system ]]; then

            text_delay ; echo " ✕ systemd detected

systemd has roughly over 1.3 million lines of code and growing each day!

WARNING:
***

Due to the size of this code base systemd is considered a massive attack surface & inefficient code compared to other Linux init systems. To improve security, we recommend switching to a distro without systemd.

***" | if [ "$gui_flag" = "1" ]; then
                zenity --text-info $default_mainmenu_gui_dimensions --title="$app_name: $probe_name Report" --cancel-label="" --timeout=10
            else
                cat | print_red
            fi

            if [ "$tui_flag" = "1" ]; then
            divider
            entertocontinue
            fi

            xprob_messages+=(" ✕ systemd: detected")
            #exit

            #else

            #xprob_messages+=(" ✓ systemd: not detected")

            #text_delay ; echo " ✓ systemd: not detected" | if [ "$tui_flag" = "1" ]; then
                #cat
            #fi
            fi



        #text_delay ; echo "Checking installed packages..."
        # Optimal for Alpine Linux, but mainstream Linux should already have these installed:

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
        #local programs=("jq" "unzip" "7z" "dig" "nano" "git" "flatpak" "zenity")  # Add more here
        local programs=("sudo" "bash" "flatpak" "zenity" "nano" "git" "jq" "tput" "chsh"  "xdg-open")  # Add more here

        for prog in "${programs[@]}"; do
        if ! command -v "$prog" &>/dev/null; then

            xprob_messages+=(" ✕ $prog is not installed")

            text_delay ; echo -e " ✕ $prog is not installed" | print_red | if [ "$tui_flag" = "1" ]; then
                cat
            fi

            missing+=("$(tool_to_pkg_name "$prog")")
            #missing+=("$prog")

        else

            xprob_messages+=(" ✓ $prog is installed")

            text_delay ; echo -e " ✓ $prog is installed" | if [ "$tui_flag" = "1" ]; then
                cat
            fi

        fi
        done


        if [ "$gui_flag" = "1" ]; then
        echo "# generating results..." >&3
        fi


        if [ ${#missing[@]} -ne 0 ]; then

            if [ "$gui_flag" = "1" ]; then
            echo "# attempting install..." >&3
            fi

            text_delay ; echo "
Attempting to install package(s):
'${missing[*]}'
" | if [ "$gui_flag" = "1" ]; then
                zenity --text-info --timeout=4 $default_mainmenu_gui_dimensions --title="$app_name: $probe_name Notification" --ok-label="" --cancel-label=""

                if [ "$package_manager" == "apt" ]; then
                    x-terminal-emulator -e bash -c "'$full_path'; echo \"\"; read -p \"Press enter to continue\";"
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

                    terminal_launched=false

                    for term in "${terminals[@]}"; do
                    cmd=($term)  # Split into command and args
                    if command -v "${cmd[0]}" &>/dev/null; then
                        "${cmd[@]}" bash -c "'$full_path'; echo \"\"; read -p \"Press enter to continue\"" #exec
                        terminal_launched=true
                        break # Exit the loop after the first successful command
                    fi
                    done

                    # Only show error if *no* terminal could be launched
                    if [[ "$terminal_launched" == false ]]; then
                        echo "No terminal emulator found. Please install xfce4-terminal, kitty, konsole, gnome-terminal, xterm, or another commonly installed terminal emulator or use this program in TUI mode." | \
                        zenity --info --title="$app_name: Notification" --text="$(cat)" $default_messagebox_gui_dimensions
                    fi
                fi

                 # exec bash
                exit
            else
                cat
                printf " 🔐 " ; $pkgmngr_refresh ; $pkgmngr_install ${missing[*]}
                #echo "Please install missing packages using this command, then restart $app_name:"
                #echo "sudo $pkgmngr_install ${missing[*]}"
                #divider
                #entertocontinue
                exit
            fi


        #spacer ; echo "Attempting to install package(s): '${missing[*]}'" ; printf " 🔐 " ; sudo apt update ; sudo $pkgmngr_install ${missing[*]} #x-terminal-emulator -e "bash -c 'printf \" 🔐 \" ; sudo apt update ; sudo $pkgmngr_install ${missing[*]}'"
        #sleep-short ; spacer ; echo "Please install missing packages using this command, then restart $app_name:"
        #echo "sudo $pkgmngr_install ${missing[*]}"
        #divider
        #entertocontinue
        return 1
        fi
        }

        # Check Programs Loop
        if check_programs; then
        #check_appimagelauncher

            if [ "$gui_flag" = "1" ]; then
            echo "# displaying report..." >&3
            fi

        sleep .3
        else

            if [ "$gui_flag" = "1" ]; then
            echo "# displaying report..." >&3
            fi

            text_delay ; echo "
Please install missing packages using this $probe_name tool or by using the command below (in a terminal), then restart $app_name:

$pkgmngr_install ${missing[*]}" | if [ "$gui_flag" = "1" ]; then
                zenity --text-info $default_mainmenu_gui_dimensions --title="$app_name: $probe_name Report" --cancel-label=""
                exit
            else
                cat | print_red
            fi

        if [ "$tui_flag" = "1" ]; then
        divider
        entertocontinue
        fi

        exit
        fi

    }

    menu () {

        display_local_scripts() {

            local dir="$1"

            # Arrays to hold .$package_manager files, names, and mapping
            local script_files=()
            local script_file_names=()
            local script_display_names=()
            local script_map=()

            # Build list of .$package_manager files
            for file in "$APPDIR/$dir/"*.$package_manager; do
            if [[ -f "$file" ]]; then
            script_files+=("$file")
            local file_name=$(basename "$file" .$package_manager)
            script_file_names+=("$file_name")
            script_display_names+=("$file_name")
            script_map+=("$file_name:$file")
            fi
            done

            # Build list of .sh files
            for file in "$APPDIR/$dir/"*.sh; do
            if [[ -f "$file" ]]; then
            script_files+=("$file")
            local file_name=$(basename "$file" .sh)
            script_file_names+=("$file_name")
            script_display_names+=("$file_name")
            script_map+=("$file_name:$file")
            fi
            done

            if [[ -f "$HOME/.MutagenesisX" || -f "$HOME/.mutagenesisx" ]]; then
                # Build list of .sh files
                for file in "$APPDIR/$dir/"*.MutagenesisX; do
                if [[ -f "$file" ]]; then
                script_files+=("$file")
                local file_name=$(basename "$file" .MutagenesisX)
                script_file_names+=("$file_name")
                script_display_names+=("$file_name")
                script_map+=("$file_name:$file")
                fi
                done
            fi

            if [ "$tui_flag" = "1" ]; then

            # Add special options
            script_file_names+=("View Action's Source Code" "<- Back")

            fi

            if [ "$gui_flag" = "1" ]; then

            # Add special options
            script_file_names+=("<- Back")

            fi

            # If no scripts found
            if [ ${#script_file_names[@]} -eq 1 ]; then
            echo "0 $app_name files detected."
            entertocontinue | center
            scriptmenusticky="0"
            return
            #break
            fi

            # Main loop — this will re-show the menu after every action
            #while true; do
            # Clear screen and redraw header + prompt
            clear && printf '\e[3J'
            mutagenesisx_banner
            echo "$app_name $app_ver_major.$app_ver_minor.$app_ver_build $app_ver_stage" | center
            echo "$mainmenuname -> $selected" | center ; divider
            echo "
Select an action to run:" | center

            # Show cursor menu
            local selection
            if [ "$gui_flag" = "1" ]; then
                selection=$(zenity --list --column="Options" "${script_file_names[@]}" $default_mainmenu_gui_dimensions --title="$app_name: $selected" --ok-label="" --cancel-label="")
                exit_code=$?
            else
                #cursor_menu " " selected "${menu[@]}"
                cursor_menu " " selection "${script_file_names[@]}"
            fi

            if [ "$exit_code" == "1" ]; then
            #loop="0"
            scriptmenusticky="0"
            return
            fi

            case "$selection" in
            "<- Back")
            scriptmenusticky="0"
            break
            ;;

            "View Action's Source Code")
            # Build edit menu
            local edit_options=("${script_display_names[@]}" "<- Back")
            local edit_selection

            # Clear and show edit header
            clear && printf '\e[3J'
            mutagenesisx_banner
            echo "$app_name $app_ver_major.$app_ver_minor.$app_ver_build $app_ver_stage" | center
            echo "$mainmenuname -> $selected" | center ; divider
            echo "
Select an action to view it's source code:" | center
            cursor_menu " " edit_selection "${edit_options[@]}"

            if [ "$edit_selection" == "<- Back" ]; then
            #continue  # Return to main menu
            return
            fi

            # Resolve path
            local full_path=""
            for entry in "${script_map[@]}"; do
            IFS=':' read -r name path <<< "$entry"
            if [[ "$name" == "$edit_selection" ]]; then
            full_path="$path"
            break
            fi
            done

            if [[ -z "$full_path" ]]; then
            echo ""
            echo "Error: Could not find the full path for $edit_selection." | center
            echo ""
            entertocontinue
            continue
            fi

            echo ""
            echo "Opening $edit_selection in the Editor..." | center
            echo ""

            # Launch editor
            nano "$full_path"
            #x-terminal-emulator -e bash -c 'exec nano "$0"' "$full_path"

            # Re-render menu after edit
            continue
            ;;

            *)
            # Run selected script
            local full_path=""
            for entry in "${script_map[@]}"; do
            IFS=':' read -r name path <<< "$entry"
            if [[ "$name" == "$selection" ]]; then
            full_path="$path"
            break
            fi
            done

            if [[ -z "$full_path" ]]; then

            if [ "$gui_flag" = "1" ]; then
                echo ""
                zenity --error --text="Error: Could not find the full path for $selection."
            else
                echo "
Error: Could not find the full path for $selection.
" | center
                entertocontinue
            fi

            continue
            fi

            #divider
            chmod +x "$full_path" >/dev/null 2>&1
            if [ "$gui_flag" = "1" ]; then
                #zenity --warning --timeout=1 --text="Running $selection..."
                exec 3> >(zenity --progress --pulsate --auto-close --text="Running $selection..." --title="$app_name: Action" $default_loading_gui_dimensions)
                echo "# Running $selection..." >&3
                sleep 1.7
                echo "100" >&3
                exec 3>&-  # Close fd
            else
                echo "
Running $selection...

$full_path" | center
                divider
                echo ""
            fi

            #export -f center
            #export -f print_red
            #export -f divider
            #export -f cursor_menu
            #export -f entertocontinue
            #export -f text_delay

            export package_manager
            export pkgmngr_install
            export pkgmngr_refresh
            export app_name
            export app_temp_loc
            export gui_flag
            export tui_flag

            #clear
            #mutagen_banner
            if [ "$gui_flag" = "1" ]; then

                if [ "$package_manager" == "apt" ]; then
                    x-terminal-emulator -e bash -c "'$full_path'; echo \"\"; read -p \"Press enter to continue\";"
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

                    terminal_launched=false

                    for term in "${terminals[@]}"; do
                    cmd=($term)  # Split into command and args
                    if command -v "${cmd[0]}" &>/dev/null; then
                        "${cmd[@]}" bash -c "'$full_path'; echo \"\"; read -p \"Press enter to continue\"" #exec
                        terminal_launched=true
                        break # Exit the loop after the first successful command
                    fi
                    done

                    # Only show error if *no* terminal could be launched
                    if [[ "$terminal_launched" == false ]]; then
                        echo "No terminal emulator found. Please install xfce4-terminal, kitty, konsole, gnome-terminal, xterm, or another commonly installed terminal emulator or use this program in TUI mode." | \
                        zenity --info --title="$app_name: Notification" --text="$(cat)" $default_messagebox_gui_dimensions
                    fi
                fi

            else
                sleep .5
                "$full_path"
                divider
                entertocontinue | center
            fi
            #"$full_path"
            #x-terminal-emulator -e bash -c "'$full_path'" &> /dev/null &
            #fi

            # Re-render the menu after running the script
            continue
            #break 2
            ;;
            esac
            #done
        }

            loop="1"

            while [ "$loop" == "1" ]; do

            if [ "$loop" == "1" ]; then clear && printf '\e[3J'

            local dir="$APPDIR"
            local menu=()
            mutagenesisx_banner
            # Build list of subdirectories
            for sub_dir in "$dir"/*; do
            if [ -d "$sub_dir" ]; then
            menu+=("${sub_dir##*/}")  # Extract dir name only
            fi
            done

            # Add "Back" option
            menu+=("View $probe_name Report" "About $app_name" "Exit $app_name")

            # If no directories found
            if [ ${#menu[@]} -eq 0 ]; then
            echo "No directories found."
            read -p "Press Enter to continue..."
            return
            fi


            echo "$app_name $app_ver_major.$app_ver_minor.$app_ver_build $app_ver_stage" | center
            mainmenuname="Main Menu" ; echo "$mainmenuname" | center ; divider
            echo "
Select a menu option:" | center
            # Use cursor menu for selection
            local selected
            if [ "$gui_flag" = "1" ]; then
                selected=$(zenity --list --column="Options" "${menu[@]}" $default_mainmenu_gui_dimensions --title="$app_name: $mainmenuname" --ok-label="" --cancel-label="")
                exit_code=$?
                if [ "$exit_code" == "1" ]; then
                loop="0"
                break 2
                exit
                fi

            else
                cursor_menu " " selected "${menu[@]}"
            fi




            # Process selection
            if [ "$selected" == "View $probe_name Report" ]; then
                if [ "$gui_flag" = "1" ]; then
                printf '%s\n' "${xprob_messages[@]}" | zenity --text-info --title="$app_name: $probe_name Report" $default_mainmenu_gui_dimensions
                else
                divider
                echo ""
                printf '%s\n' "${xprob_messages[@]}"
                divider
                entertocontinue
                fi
            continue
            fi

            if [ "$selected" == "About $app_name" ]; then
            credits
            continue
            fi

            if [ "$selected" == "Exit $app_name" ]; then
            #softwaremenusticky="0"
            break 2

            else

            #if [ "$gui_flag" = "1" ]; then
            #display_local_scripts "$selected"
            #fi

            #if [ "$tui_flag" = "1" ]; then
            scriptmenusticky="1"
            while [ "$scriptmenusticky" == "1" ]; do
            clear && printf '\e[3J'
            echo "$app_name $app_ver_major.$app_ver_minor.$app_ver_build $app_ver_stage -> Categories -> $selected" | center ; divider
            echo
            display_local_scripts "$selected"
            done
            #fi

            fi

            fi
            done

    }

}

clear

mutagenesisx-shell ; sleep .5

# GUI/TUI Switcher
if [ -t 0 ]; then
    # TERMINAL
    tui_flag="1"

else
    # GUI
    gui_flag="1"

fi

eula_prompt

mutagenesisx_banner

if [ "$gui_flag" = "1" ]; then
    #( $probe_name ) | zenity --progress --pulsate --auto-close --text="Running $probe_name..." --title="Processing"
    # Send progress updates to Zenity on a separate file descriptor
    exec 3> >(zenity --progress --pulsate --auto-close --text="Running $probe_name..." --title="$app_name: $probe_name Analysis" $default_loading_gui_dimensions --no-cancel)
    echo "# scanning system..." >&3
    xprobe
    echo "100" >&3
    exec 3>&-  # Close fd
    printf '%s\n' "${xprob_messages[@]}" | zenity --text-info --title="$app_name: $probe_name Report" --timeout=7 $default_mainmenu_gui_dimensions #--ok-label="" --cancel-label=""
    #exit
else
    xprobe
fi

if [ "$tui_flag" = "1" ]; then

#sleep 1.5
sleep 3

fi

menu

credits

clear
