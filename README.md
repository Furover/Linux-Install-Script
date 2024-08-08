# Useful commands
- sudo modprobe v4l2loopback video_nr=9 card_label=Camera exclusive_caps=1
- scrcpy --video-source=camera --camera-id=0 --camera-size=3840x2160 --video-bit-rate=20M --v4l2-sink=/dev/video9 --no-playback
- sudo ufw default deny outgoing
- sudo ufw allow out on tun0
- sudo ufw allow out to IP:Range port 0000 proto Protocol

# NVIDIA commands
Services required to run wayland on gnome:
- systemctl enable nvidia-suspend
- systemctl enable nvidia-resume
- systemctl enable nvidia-hibernate

Force wayland:
- ln -s /dev/null /etc/udev/rules.d/61-gdm.rules

# Explanation
- nvidia.hook goes to /etc/pacman.d/hooks/ so that everytime there's an update to the nvidia driver, it updates the initramfs
- arch.conf goes to /boot/loader/entries/ (self explanatory)
- install-stuff.sh is my script that installs my essential apps on Fedora or Arch
