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

    package_manager="$(for cmd in apt dnf yum pacman zypper; do
    command -v $cmd &>/dev/null && echo $cmd && break
    done)"

    pkgmngr_install="apt install"

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

    echo "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⠏⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⣿⣿⡟⣠⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣯⠀⠀⠀⠀⠄⠉⠉⠉⠛⠻⢿⠋⣿⣿⣿⣿⣿⣿⢃⠀⣿⡿⢱⣿⣸⣿⣿⣿⣿⣿⡏⣿⣿⠛⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣧⡀⠀⠂⣾⣿⣿⣿⣶⣶⡆⣠⢸⣻⠿⠿⣿⡟⢸⠀⣿⢃⣾⣿⡏⣿⣿⣿⣿⣿⠀⢻⡏⡄⢡⡜⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⠶⡄⠘⢿⣿⣿⣿⣿⢃⣿⢸⣿⡟⢳⣶⢁⣟⠀⢇⣾⣿⣿⡇⢻⣿⣿⠀⡟⢀⢸⢱⣧⣾⣿⡘⢛⣛⣛⣛⣛⣛⣻⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣶⣶⣶⣦⣐⢶⣶⣶⣾⣿⡏⡟⢸⡄⠇⣼⣿⠀⣰⣽⣿⡻⢷⢸⣿⡇⣤⠀⣿⠀⣾⣿⣿⣿⣿⣷⣽⡻⢿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣿⣿⣿⣿⡇⢠⣿⣿⣴⣿⣿⣷⣿⣿⣿⣿⣷⡄⣟⢀⢿⣾⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣦⠙⠻⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠃⣼⣿⣶⣭⣙⡛⠿⠿⢿⣿⣿⣿⣿⣿⣷⠀⠈⠻⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⢠⣿⣿⣿⣿⣿⣿⣷⣶⣤⣄⣈⡉⠉⠉⠀⠀⠀⠀⠈⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣶⣤⣴⣾⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿

Presented By:
https://jcorestudios.com/
https://github.com/jcore92

$app_name $app_ver_major.$app_ver_minor.$app_ver_build $app_ver_stage

Infused with MutagenesisX, GhostAPT, and Command Center's DNA. (Various older predecessor's of MutagenesisX.)

jcore92 - Lead Programmer/MutagenesisX Author" | zenity --text-info --title="About $app_name" --width=580 --height=600 #--ok-label="" --cancel-label="" &

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

    echo "$app_name $app_ver_major.$app_ver_minor.$app_ver_build $app_ver_stage
" | center

    echo "Infused with MutagenesisX, GhostAPT, and Command Center's DNA.
(Various older predecessor's of MutagenesisX.)

jcore92 - Lead Programmer/MutagenesisX Author" | center

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

        if zenity --text-info --title="$app_name: EULA" --width=580 --height=600 --filename="$APPDIR/LICENSE" --ok-label="I Agree"; then
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

        if [ "$XDG_SESSION_TYPE" = "tty" ]; then

            text_delay ; echo " ✕ TTY is not supported. Please use a Desktop Environment to open $app_name." | if [ "$gui_flag" = "1" ]; then
                zenity --text-info --width=580 --height=600
            else
                cat
                entertocontinue
            fi

        exit
        fi


        if [ -n "$WSL_DISTRO_NAME" ] || [ -n "$IS_WSL" ]; then

            text_delay ; echo " ✕ WSL is not supported." | if [ "$gui_flag" = "1" ]; then
                zenity --text-info --width=580 --height=600
            else
                cat
                entertocontinue
            fi

        exit
        fi



        # Get system's pretty name to display
        prettyname="$(cat /etc/os-release | grep "PRETTY_NAME" | awk -F '"' '{print $2}')"

        # Check the /etc/os-release file for any trace of Ubuntu or Debian: ubuntu debian
        if grep -qi "ubuntu" /etc/os-release; then

            xprob_messages+=(" ✓ $prettyname (Ubuntu-based)")
            xprob_messages+=(" ✓ Desktop Environment: $XDG_CURRENT_DESKTOP")
            xprob_messages+=(" ✓ Display Server: $XDG_SESSION_TYPE")

            text_delay ; echo " ✓ $prettyname (Ubuntu-based)" | if [ "$tui_flag" = "1" ]; then
                cat
            fi

            text_delay ; echo " ✓ Desktop Environment: $XDG_CURRENT_DESKTOP" | if [ "$tui_flag" = "1" ]; then
                cat
            fi

            text_delay ; echo " ✓ Display Server: $XDG_SESSION_TYPE" | if [ "$tui_flag" = "1" ]; then
                cat
            fi

        elif grep -qi "debian" /etc/os-release; then

            xprob_messages+=(" ✓ $prettyname (Debian-based)")
            xprob_messages+=(" ✓ Desktop Environment: $XDG_CURRENT_DESKTOP")
            xprob_messages+=(" ✓ Display Server: $XDG_SESSION_TYPE")

            text_delay ; echo " ✓ $prettyname (Debian-based)" | if [ "$tui_flag" = "1" ]; then
                cat
            fi

            text_delay ; echo " ✓ Desktop Environment: $XDG_CURRENT_DESKTOP" | if [ "$tui_flag" = "1" ]; then
                cat
            fi

            text_delay ; echo " ✓ Display Server: $XDG_SESSION_TYPE" | if [ "$tui_flag" = "1" ]; then
                cat
            fi

        else

            if [ "$gui_flag" = "1" ]; then
            echo "# generating results..." >&3
            sleep 1
            echo "# displaying report..." >&3
            fi

            text_delay ; echo " ✕ Neither Ubuntu nor Debian base found." | if [ "$gui_flag" = "1" ]; then
                zenity --text-info --width=500 --height=600 --title="$app_name: $probe_name Report" --cancel-label=""
            else
                cat | print_red
            fi

            if [ "$tui_flag" = "1" ]; then
            divider
            entertocontinue
            fi
            exit
        fi

        #text_delay ; echo "Checking package manager..."

        if [ "$package_manager" != "apt" ]; then

            if [ "$gui_flag" = "1" ]; then
            echo "# generating results..." >&3
            sleep 1
            echo "# displaying report..." >&3
            fi

            text_delay ; echo " ✕ Unsupported package manager '$package_manager'. APT is currently only supported." | if [ "$gui_flag" = "1" ]; then
                zenity --text-info --width=500 --height=600 --title="$app_name: $probe_name Report" --cancel-label=""
                exit
            else
                cat | print_red
            fi

            if [ "$tui_flag" = "1" ]; then
            divider
            entertocontinue
            fi

            exit

        else

            xprob_messages+=(" ✓ apt is installed")

            text_delay ; echo " ✓ apt is installed" | if [ "$tui_flag" = "1" ]; then
                cat
            fi
        fi

        #text_delay ; echo "Checking installed packages..."

        tool_to_pkg_name() {
        case "$1" in
        "7z") echo "7zip" ;;
        #"7z")  echo "p7zip-full" ;;
        "dig")  echo "dnsutils" ;;
        "sha256sum")  echo "coreutils" ;;
        *)     echo "$1" ;;
        esac
        }

        #

        check_programs() {
        declare -g missing=()
        #local programs=("jq" "unzip" "7z" "dig" "nano" "git" "flatpak" "zenity")  # Add more here
        local programs=("jq" "nano" "git" "flatpak" "zenity")  # Add more here

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
                zenity --text-info --timeout=3 --width=500 --height=600 --title="$app_name: $probe_name Notification" --ok-label="" --cancel-label=""
                x-terminal-emulator -e bash -c "printf \" 🔐 \" ; sudo apt update ; sudo $pkgmngr_install ${missing[*]}; echo \"\"; read -p \"Press enter to continue\";" # exec bash
                exit
            else
                cat
                printf " 🔐 " ; sudo apt update ; sudo $pkgmngr_install ${missing[*]}
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

sudo $pkgmngr_install ${missing[*]}" | if [ "$gui_flag" = "1" ]; then
                zenity --text-info --width=500 --height=600 --title="$app_name: $probe_name Report" --cancel-label=""
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

        # At the end of the script
        #if [ "$gui_flag" = "1" ]; then
        #    printf '%s\n' "${xprob_messages[@]}" | zenity --text-info --title="$app_name: $probe_name report" --width=800 --height=600 --ok-label="Close"
        #    exit
        #fi

    }

    menu () {

        display_local_scripts() {

            local dir="$1"

            # Arrays to hold .sh files, names, and mapping
            local script_files=()
            local script_file_names=()
            local script_display_names=()
            local script_map=()

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
                #echo "${menu[@]}" | zenity --text-info --width=600 --height=800 --title="$app_name: $mainmenuname" --cancel-label=""
                selection=$(zenity --list --column="Options" "${script_file_names[@]}" --width=500 --height=600 --title="$app_name: $selected" --ok-label="" --cancel-label="")
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
                exec 3> >(zenity --progress --pulsate --auto-close --text="running $selection..." --title="$app_name: Action" --width=400 --height=200)
                echo "# running $selection..." >&3
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

            export -f center
            export -f print_red
            export -f divider
            export -f cursor_menu
            export -f entertocontinue
            export -f text_delay

            export pkgmngr_install
            export app_name
            export app_temp_loc
            export gui_flag
            export tui_flag

            #clear
            #mutagen_banner
            if [ "$gui_flag" = "1" ]; then
                x-terminal-emulator -e bash -c "'$full_path'; echo \"\"; read -p \"Press enter to continue\";" # exec bash
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
            menu+=("About $app_name" "Exit $app_name")

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
                #echo "${menu[@]}" | zenity --text-info --width=600 --height=800 --title="$app_name: $mainmenuname" --cancel-label=""
                selected=$(zenity --list --column="Options" "${menu[@]}" --width=500 --height=600 --title="$app_name: $mainmenuname" --ok-label="" --cancel-label="")
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
    exec 3> >(zenity --progress --pulsate --auto-close --text="Running $probe_name..." --title="$app_name: $probe_name Analysis" --width=400 --height=200 --no-cancel)
    echo "# scanning system..." >&3
    xprobe
    echo "100" >&3
    exec 3>&-  # Close fd
    printf '%s\n' "${xprob_messages[@]}" | zenity --text-info --title="$app_name: $probe_name Report" --timeout=3 --width=500 --height=600 #--ok-label="" --cancel-label=""
    #exit
else
    xprobe
fi

if [ "$tui_flag" = "1" ]; then

sleep 1.5

fi

menu

credits

clear
