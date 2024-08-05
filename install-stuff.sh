MANAGER=""

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

checkEnv() {
    ## Check for requirements.
    REQUIREMENTS='curl groups sudo'
    for req in $REQUIREMENTS; do
        if ! command_exists "$req"; then
            echo "${RED}To run me, you need: $REQUIREMENTS${RC}"
            exit 1
        fi
    done

    ## Check Package Handler
    PACKAGEMANAGER='apt dnf pacman'
    for pgm in $PACKAGEMANAGER; do
        if command_exists "$pgm"; then
            MANAGER="$pgm"
            echo "Using $pgm"
            break
        fi
    done

    if [ -z "$MANAGER" ]; then
        echo "${RED}Can't find a supported package manager${RC}"
        exit 1
    fi
}

askPackages(){
	# Prompt the user for input
	read -p "Install packages?: " packageresponse

	# Convert the response to lowercase for case-insensitive comparison
	packageresponse=$(echo "$packageresponse" | tr '[:upper:]' '[:lower:]')

	# Check the user's response
	if [[ "$packageresponse" == "yes" || "$packageresponse" == "y" ]]; then
	    if [[ "$MANAGER" == "pacman" ]]; then
            if ! command_exists yay; then
                echo "Installing yay as AUR helper..."
                sudo ${MANAGER} -S base-devel
                mkdir -p ~/Repositories/Tools
                cd ~/Repositories/Tools && git clone https://aur.archlinux.org/yay-git.git
                cd yay-git && makepkg --noconfirm -si
            else
                echo "AUR helper already installed"
            fi
            sudo ${MANAGER} -Sy ufw networkmanager-openvpn gnome-tweaks nextcloud-client firefox-developer-edition gimp inkscape lutris steam tilix scrcpy obs-studio android-tools code libreoffice-fresh v4l2loopback-dkms celluloid lollypop audacity clamtk firejail btop fastfetch gnome-shell-extension-caffeine gnome-shell-extension-weather-oclock gnome-shell-extension-appindicator
            sudo ${MANAGER} -Rcuns totem gnome-contacts gnome-console evince gnome-tour simple-scan snapshot gnome-maps gnome-music
            yay -S portmaster-stub-bin
            sudo ${MANAGER} --noconfirm -S sushi
            flatpak install flathub com.spotify.Client dev.vencord.Vesktop com.github.finefindus.eyedropper io.github.seadve.Mousai com.vscodium.codium com.github.tchx84.Flatseal net.davidotek.pupgui2 io.itch.itch com.brave.Browser io.gitlab.librewolf-community org.mozilla.Thunderbird

            #This changes nautilus to the default file manager, I don't know why, but whenever I install codium, it changes this
            xdg-mime default org.gnome.Nautilus.desktop inode/directory application/x-gnome-saved-search

            ##This is supposed to change the "Open in terminal" Nautilus button to open in tilix, but it didn't work, so I'm just leaving in here in case I figure something out
            #gsettings set org.gnome.desktop.default-applications.terminal exec /usr/bin/tilix
            #gsettings set org.gnome.desktop.default-applications.terminal exec-arg "-x"

            ##You could also just remove the gnome-terminal and link tilix with it's name, but I thought that was a bad idea, so I didn't do it
            #sudo ${MANAGER} -Rcuns gnome-terminal
            #sudo ln -s /usr/bin/tilix /usr/bin/gnome-terminal

            while true; do
                read -p "Install flatpak or $MANAGER version of Firefox?(f/p): " firefoxresponse

               	firefoxresponse=$(echo "$firefoxresponse" | tr '[:upper:]' '[:lower:]')

                if [[ "$firefoxresponse" == "f" ]]; then
                    flatpak install flathub org.mozilla.firefox
                    break
                elif [[ "$firefoxresponse" == "p" ]]; then
                    sudo ${MANAGER} --noconfirm -S firefox
                    break
                fi

            done

            read -p "Install lutris junk?: " lutrisresponse

            lutrisresponse=$(echo "$lutrisresponse" | tr '[:upper:]' '[:lower:]')

           	if [[ "$lutrisresponse" == "yes" || "$lutrisresponse" == "y" ]]; then
                sudo ${MANAGER} --noconfirm -S wine-staging
                sudo ${MANAGER} --noconfirm -S --needed --asdeps giflib lib32-giflib gnutls lib32-gnutls v4l-utils lib32-v4l-utils libpulse \
                lib32-libpulse alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib sqlite lib32-sqlite libxcomposite \
                lib32-libxcomposite ocl-icd lib32-ocl-icd libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs \
                lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader sdl2 lib32-sdl2
            else
                echo "Continuing without installing lutris stuff"
            fi

            read -p "Do ya want virtual machines?: " virtualresponse

            virtualresponse=$(echo "$virtualresponse" | tr '[:upper:]' '[:lower:]')

           	if [[ "$virtualresponse" == "yes" || "$virtualresponse" == "y" ]]; then
                sudo ${MANAGER} --noconfirm -S qemu-full
            else
                echo "Continuing without installing vm stuff"
            fi

        fi

        if [[ "$MANAGER" == "dnf" ]]; then
            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            sudo ${MANAGER} copr enable zeno/scrcpy
            sudo ${MANAGER} in ufw sushi gnome-tweaks nextcloud-client gimp inkscape lutris steam tilix scrcpy obs-studio celluloid lollypop audacity clamtk btop fastfetch flatseal wine-core wine-core.i686 firejail gnome-shell-extension-caffeine gnome-shell-extension-unite gnome-shell-extension-appindicator gnome-shell-extension-forge gnome-shell-extension-just-perfection gnome-shell-extension-dash-to-dock
            sudo ${MANAGER} rm firewalld totem gnome-contacts evince gnome-tour simple-scan snapshot gnome-maps
            flatpak install flathub com.spotify.Client dev.vencord.Vesktop com.github.finefindus.eyedropper io.github.seadve.Mousai net.davidotek.pupgui2 io.itch.itch com.brave.Browser io.gitlab.librewolf-community org.mozilla.Thunderbird

            while true; do
                read -p "Install flatpak or $MANAGER version of Firefox?(f/d): " firefoxresponse

               	firefoxresponse=$(echo "$firefoxresponse" | tr '[:upper:]' '[:lower:]')

                if [[ "$firefoxresponse" == "f" ]]; then
                    flatpak install flathub org.mozilla.firefox
                    break
                elif [[ "$firefoxresponse" == "d" ]]; then
                    sudo ${MANAGER} in firefox
                    break
                fi

            done

            read -p "Do ya want virtual machines?: " virtualresponse

            virtualresponse=$(echo "$virtualresponse" | tr '[:upper:]' '[:lower:]')

           	if [[ "$virtualresponse" == "yes" || "$virtualresponse" == "y" ]]; then
                sudo ${MANAGER} in @Virtualization
            else
                echo "Continuing without installing vm stuff"
            fi

        fi

    else
        echo "Continuing without installing packages"
	fi
}

askForge(){
	read -p "Are you using/going to use forge?: " forgeresponse


	forgeresponse=$(echo "$forgeresponse" | tr '[:upper:]' '[:lower:]')


	if [[ "$forgeresponse" == "yes" || "$forgeresponse" == "y" ]]; then
		echo "Changing settings..."
		gsettings set org.gnome.mutter focus-change-on-pointer-rest false #changes focus on hover instantly
		gsettings set org.gnome.desktop.wm.preferences button-layout : #removes all buttons from the top
	else
		echo "Finishing without changing settings for forge."
	fi
}

checkEnv
askPackages
askUfw
askForge

echo "Finished job"
