# Useful commands
- scrcpy --video-source=camera --camera-id=0 --camera-size=3840x2160 --video-bit-rate=20M --v4l2-sink=/dev/video0 --no-playback
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
