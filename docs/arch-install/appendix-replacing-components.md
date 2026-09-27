# Appendix A: Replacing desktop components later

Some desktop pieces installed in [3.2](03-base-install.md#hyprland) are stand-ins until Quickshell-based replacements exist. This appendix lists what to keep, what to remove, and how.

## Hyprland packages

| Package | When Quickshell takes over |
|---|---|
| hyprland, xdg-desktop-portal-hyprland, xdg-desktop-portal-gtk, uwsm | keep |
| qt5-wayland / qt6-wayland | keep qt6 (Quickshell needs it); qt5 only if a Qt5 app needs it |
| kitty | keep / swap for another terminal |
| dunst | **remove** once a Quickshell notification server runs: `sudo pacman -Rns dunst`, and remove its `hl.exec_cmd("dunst")` autostart line if you added one |
| hyprlauncher | **remove** once a Quickshell launcher exists: `sudo pacman -Rns hyprlauncher`, and point `local menu = "hyprlauncher"` in `hyprland.lua` at the new launcher |
| hyprpolkitagent | **replace** if you build a Quickshell polkit agent: `sudo systemctl --global disable hyprpolkitagent.service` (it was enabled globally in [7.2](07-desktop-services.md#72-hyprland-profile-and-polkit)), then `sudo pacman -Rns hyprpolkitagent`. Only one agent may run. |
| nautilus | keep |
| grim / slurp | keep (Quickshell screenshot tools often call them) |

## Network GUI

This guide installs no network GUI; `nmtui` / `nmcli` handle Wi-Fi ([5.4](05-system-basics.md#54-network)). If you build a Quickshell network widget, make it register as a NetworkManager **secret agent**: when NetworkManager needs a password (new Wi-Fi, VPN, 802.1X) it asks a registered agent to prompt you, and with **no** agent a GUI connection that needs a password fails silently. `nmcli --ask` and `nmtui` prompt on their own.

For a GUI stopgap, `network-manager-applet` provides both a tray icon (needs a bar with a tray, started with `nm-applet --indicator`) and the secret agent, plus `nm-connection-editor` for static IPs, VPNs and hotspots.

## Greeter

Moving from tuigreet ([7.3](07-desktop-services.md#73-greeter-greetd-and-tuigreet)) to a Quickshell greeter:

1. Build and install your Quickshell greeter. greetd runs it as its session command, usually `Hyprland` or `cage` running `quickshell -p /path/to/greeter`.
2. **Edit** `/etc/greetd/config.toml`: change the `command = …` line under `[default_session]` to your greeter command. Keep `user = "greeter"`. Put the greeter files somewhere the `greeter` user can read (e.g. `/etc/greetd/quickshell/`).
3. Test it: switch to a second TTY (`Ctrl+Alt+F2`), log in there as a fallback, then run `sudo systemctl restart greetd`.
4. Once it works: `sudo pacman -Rns greetd-tuigreet`. Keep the `[initial_session]` auto-login block; it's independent of the greeter.

---

Back to [the index](README.md)
