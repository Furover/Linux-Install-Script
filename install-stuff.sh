MANAGER=""
FIRSTINSTALL=false
goBack=$(pwd)
echo "Make sure you're running this on the folder of this repository"
echo "Directory: ${goBack}"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

checkEnv() {
    cd ~
    ## Check for requirements.
    REQUIREMENTS='curl groups sudo git wget'
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

			read -p "Install desktop environment and other stuff (First Arch install)?: " archresponse

			archresponse=$(echo "$archresponse" | tr '[:upper:]' '[:lower:]')

			if [[ "$archresponse" == "yes" || "$archresponse" == "y" ]]; then

			    FIRSTINSTALL=true
			    sudo ${MANAGER} --noconfirm -Sy wayland xorg-xwayland pipewire pipewire-pulse wireplumber
				sudo ${MANAGER} -S xorg-server xorg-apps
				sudo ${MANAGER} -S gnome gnome-tweaks power-profiles-daemon
				sudo modprobe nvidia NVreg_PreserveVideoMemoryAllocations=1
				sudo systemctl enable nvidia-{suspend,resume,hibernate}
				ln -s /dev/null /etc/udev/rules.d/61-gdm.rules
				sudo systemctl enable gdm
				echo "Finished, make sure the file /etc/modprobe.d/nvidia.conf exists..."
			else
                echo "Continuing without installing base packages..."
			fi

            if ! command_exists yay; then
                echo "Installing yay as AUR helper..."
                sudo ${MANAGER} -S base-devel
                mkdir -p ~/Repositories/Tools
                cd ~/Repositories/Tools && git clone https://aur.archlinux.org/yay-git.git
                cd yay-git && makepkg --noconfirm -si && cd ${goBack}
            else
                echo "AUR helper already installed"
            fi

            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            sudo ${MANAGER} -Sy ufw fzf zoxide networkmanager-openvpn gnome-tweaks nextcloud-client firefox-developer-edition gimp inkscape lutris steam tilix scrcpy obs-studio android-tools code libreoffice-fresh v4l2loopback-dkms celluloid lollypop audacity clamtk firejail btop fastfetch gnome-shell-extension-caffeine gnome-shell-extension-weather-oclock gnome-shell-extension-appindicator
            sudo ${MANAGER} -Rcuns totem gnome-contacts gnome-console evince gnome-tour simple-scan snapshot gnome-maps gnome-music
            yay -S portmaster-stub-bin
            sudo ${MANAGER} --noconfirm -S sushi unzip
            flatpak install flathub com.spotify.Client dev.vencord.Vesktop com.github.finefindus.eyedropper io.github.seadve.Mousai com.vscodium.codium com.github.tchx84.Flatseal net.davidotek.pupgui2 io.itch.itch com.brave.Browser io.gitlab.librewolf-community org.mozilla.Thunderbird net.nokyan.Resources

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
                echo "Continuing without installing lutris stuff..."
            fi

            read -p "Do ya want virtual machines?: " virtualresponse

            virtualresponse=$(echo "$virtualresponse" | tr '[:upper:]' '[:lower:]')

           	if [[ "$virtualresponse" == "yes" || "$virtualresponse" == "y" ]]; then
                sudo ${MANAGER} --noconfirm -S qemu-full
            else
                echo "Continuing without installing vm stuff..."
            fi

        fi

        if [[ "$MANAGER" == "dnf" ]]; then

            read -p "Install nvidia drivers? (enable rpm fusion repositories): " nvidiaresponse

			nvidiaresponse=$(echo "$nvidiaresponse" | tr '[:upper:]' '[:lower:]')

			if [[ "$nvidiaresponse" == "yes" || "$nvidiaresponse" == "y" ]]; then

			    FIRSTINSTALL=true
			    sudo ${MANAGER} in akmod-nvidia
				sudo ${MANAGER} in xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-power
				sudo systemctl enable nvidia-{suspend,resume,hibernate}

				read -p "Use secure boot?: " secureresponse

                secureresponse=$(echo "$secureresponse" | tr '[:upper:]' '[:lower:]')

                if [[ "$secureresponse" == "yes" || "$secureresponse" == "y" ]]; then

                    sudo ${MANAGER} in kmodtool akmods mokutil openssl
                    sudo kmodgenca -a
                    sudo mokutil --import /etc/pki/akmods/certs/public_key.der

                else
                    echo "Continuing without configuring secure boot..."
                fi

            else
                echo "Continuing without installing nvidia drivers..."
			fi

            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            sudo ${MANAGER} copr enable zeno/scrcpy
            sudo ${MANAGER} in ufw fzf zoxide unzip sushi gnome-tweaks nextcloud-client gimp inkscape lutris steam tilix scrcpy obs-studio celluloid lollypop audacity clamtk btop fastfetch flatseal wine-core wine-core.i686 firejail gnome-shell-extension-caffeine gnome-shell-extension-unite gnome-shell-extension-appindicator gnome-shell-extension-forge gnome-shell-extension-just-perfection gnome-shell-extension-dash-to-dock
            sudo ${MANAGER} rm firewalld totem gnome-contacts evince gnome-tour simple-scan snapshot gnome-maps
            flatpak install flathub com.spotify.Client dev.vencord.Vesktop com.github.finefindus.eyedropper io.github.seadve.Mousai net.davidotek.pupgui2 io.itch.itch com.brave.Browser io.gitlab.librewolf-community org.mozilla.Thunderbird net.nokyan.Resources

            while true; do
                read -p "Install flatpak or $MANAGER version of Firefox?(f/d): " firefoxresponse

               	firefoxresponse=$(echo "$firefoxresponse" | tr '[:upper:]' '[:lower:]')

                if [[ "$firefoxresponse" == "f" ]]; then
		    sudo ${MANAGER} rm firefox
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
                echo "Continuing without installing vm stuff..."
            fi

        fi

    else
        echo "Continuing without installing packages..."
	fi
}

askForge(){
	read -p "Are you using forge?: " forgeresponse


	forgeresponse=$(echo "$forgeresponse" | tr '[:upper:]' '[:lower:]')


	if [[ "$forgeresponse" == "yes" || "$forgeresponse" == "y" ]]; then
		echo "Changing settings..."
		gsettings set org.gnome.mutter focus-change-on-pointer-rest false #changes focus on hover instantly
		gsettings set org.gnome.desktop.wm.preferences button-layout : #removes all buttons from the top
	else
		echo "Continuing without changing settings for forge..."
	fi
}

askTheme(){
	read -p "Install Colloid theme?: " themeresponse


	themeresponse=$(echo "$themeresponse" | tr '[:upper:]' '[:lower:]')


	if [[ "$themeresponse" == "yes" || "$themeresponse" == "y" ]]; then
		mkdir -p Repositories/Themes
		cd ~/Repositories/Themes
		echo "Cloning repositories..."
		git clone https://github.com/vinceliuice/Colloid-gtk-theme.git
		git clone https://github.com/vinceliuice/Colloid-icon-theme.git
		echo "Installing icon theme..."
		cd Colloid-icon-theme && ./install.sh -t pink && cd ..
		echo "Installing gtk theme..."
		cd Colloid-gtk-theme && ./install.sh -t pink -c dark -l --tweaks black --tweaks rimless && cd ..
		echo "Getting cursor..."
		wget https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/Bibata-Modern-Classic.tar.xz
		tar -xvf Bibata-Modern-Classic.tar.xz && rm -f Bibata-Modern-Classic.tar.xz
		echo "Pasting cursor into icons directory..."
		cp -r Bibata-Modern-Classic ~/.local/share/icons/ && rm -rf Bibata-Modern-Classic
		echo "Setting themes..."
		gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Classic
		gsettings set org.gnome.desktop.interface gtk-theme Colloid-Pink-Dark
		gsettings set org.gnome.desktop.interface icon-theme Colloid-Pink-Dark
		echo "Copying icons..."
		cp ${goBack}/Icons/{eyedropper.svg,itch-app.svg,mousai.svg,notion.svg,portmaster.svg,zed.svg} ~/.local/share/icons/Colloid-Pink-Light/apps/scalable/
		ln -s ~/.local/share/icons/Colloid-Pink-Light/apps/scalable/discord.svg ~/.local/share/icons/Colloid-Pink-Light/apps/scalable/dev.vencord.Vesktop.svg
		echo "Copying desktop files..."
		cp ${goBack}/Desktop/{com.github.finefindus.eyedropper.desktop,dev.vencord.Vesktop.desktop,io.github.seadve.Mousai.desktop,io.itch.itch.desktop,net.nokyan.Resources.desktop,portmaster.desktop,net.davidotek.pupgui2.desktop} ~/.local/share/applications/
		cd ${goBack}
	else
		echo "Continuing without installing gtk theme..."
	fi
}

askStarship(){
    read -p "Install Starship?: " starshipresponse


	starshipresponse=$(echo "$starshipresponse" | tr '[:upper:]' '[:lower:]')


	if [[ "$starshipresponse" == "yes" || "$starshipresponse" == "y" ]]; then
	   cd ${goBack}
	   echo "Getting new fonts..."
	   wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/RobotoMono.zip
	   mkdir ~/.local/share/fonts
	   unzip RobotoMono.zip -d ~/.local/share/fonts
	   fc-cache -vf
	   rm -f ~/.local/share/fonts/{LICENSE.txt,README.md}
	   echo "Changing Fastfetch config..."
	   mkdir ~/.config/fastfetch
	   cp ~/.config/fastfetch/config.jsonc Config/fastfetch/config-bak.jsonc
	   cp -f Config/fastfetch/config.jsonc ~/.config/fastfetch/
	   echo "Getting starship..."
	   curl -sS https://starship.rs/install.sh | sh
	   cp -f Config/starship.toml ~/.config/
	   echo "Editing .bashrc..."
	   cp ~/.bashrc .bashrc-bak
	   cp -f .bashrc ~/
	   echo "Done, remember to change your monospace font to RobotoMono."
	else
		echo "Finishing without installing starship."
	fi
}

checkEnv
askPackages
askForge
askTheme
askStarship

echo "Finished job."
if [[ "$FIRSTINSTALL" == true ]]; then
    echo "You may now reboot your pc."
fi
