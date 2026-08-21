-- Personal autostart commands
o.exec_on_start("chmod +x " .. (os.getenv("HOME") or "") .. "/.config/scripts/*.sh " .. (os.getenv("HOME") or "") .. "/.config/hypr/toggle-layout.sh")
o.exec_on_start("/usr/bin/gnome-keyring-daemon --start --components=secrets")
