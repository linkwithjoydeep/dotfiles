# Appendix A: Replacing desktop components later

Some desktop pieces installed in [3.2](03-base-install.md#hyprland) are stand-ins until Quickshell-based replacements exist. This appendix lists what to keep, what to remove, and how.

## Hyprland packages

| Package | When Quickshell takes over |
|---|---|
| hyprland, xdg-desktop-portal-hyprland, uwsm | keep |
| qt5-wayland / qt6-wayland | keep qt6 (Quickshell needs it); qt5 only if a Qt5 app needs it |
| kitty | keep / swap for another terminal |
| dunst | **remove** once a Quickshell notification server runs: `sudo pacman -Rns dunst`, and remove its `hl.exec_cmd("dunst")` autostart line if you added one |
| hyprlauncher | **remove** once a Quickshell launcher exists: `sudo pacman -Rns hyprlauncher`, and point `local menu = "hyprlauncher"` in `hyprland.lua` at the new launcher |
| hyprpolkitagent | **replace** if you build a Quickshell polkit agent: `sudo systemctl --global disable hyprpolkitagent.service` (it was enabled globally in [7.2](07-desktop-services.md#72-hyprland-profile-and-polkit)), then `sudo pacman -Rns hyprpolkitagent`. Only one agent may run. |
| network-manager-applet | **remove** once a Quickshell network widget exists ([see below](#network-manager-applet)) |
| nautilus | keep |
| grim / slurp | keep (Quickshell screenshot tools often call them) |

## network-manager-applet

### How it works

`nm-applet` is a small GTK helper for NetworkManager. It does two jobs:
1. **Tray icon + menu**: shows connection status and lets you switch Wi-Fi, toggle radios and connect VPNs. It also pulls in `nm-connection-editor`, a GUI for editing connections (static IP, VPN, hotspot).
2. **Secret agent**: when NetworkManager needs a password (new Wi-Fi, VPN, 802.1X), it asks a registered agent to prompt you. `nm-applet` is that agent. With **no** agent running, a GUI connection that needs a password fails silently.

On Hyprland it's a **convenience, not a requirement**:
- Hyprland has no built-in tray. The icon only shows in a bar that supports tray icons (Waybar, Quickshell `SystemTray`) and when started with `--indicator` (Wayland-friendly tray protocol). With no bar the icon is invisible, but the password agent still works.
- `NetworkManager.service` ([5.4](05-system-basics.md#54-network)) does the actual networking. Ethernet connects automatically and saved Wi-Fi networks reconnect without the applet.
- Terminal alternatives: `nmtui` (menu interface) or `nmcli device wifi connect "SSID" --ask`.

**Autostart:** the package ships `/etc/xdg/autostart/nm-applet.desktop`, which uwsm should run automatically. If the icon doesn't appear, start it from the autostart section of `~/.config/hypr/hyprland.lua`:
```lua
hl.on("hyprland.start", function()
  hl.exec_cmd("uwsm app -- nm-applet --indicator")
end)
```

### Removal

Once a Quickshell network widget handles listing networks + password prompts:
1. Stop it: `pkill nm-applet`
2. Optional, to keep the connection editor GUI: `sudo pacman -D --asexplicit nm-connection-editor` (otherwise the next step removes it too)
3. Remove it: `sudo pacman -Rns network-manager-applet` (keep `networkmanager` itself!)
4. Delete any `hl.exec_cmd("uwsm app -- nm-applet …")` line from `hyprland.lua` (and the `hl.on("hyprland.start", …)` block around it if it's now empty).
5. Confirm networking still works: `nmcli general status`

Make sure your Quickshell widget registers as a NetworkManager **secret agent** (or keep `nmtui` handy). Otherwise connecting to new password-protected networks from the GUI won't prompt.

## Greeter

Moving from tuigreet ([7.3](07-desktop-services.md#73-greeter-greetd-and-tuigreet)) to a Quickshell greeter:

1. Build and install your Quickshell greeter. greetd runs it as its session command, usually `Hyprland` or `cage` running `quickshell -p /path/to/greeter`.
2. **Edit** `/etc/greetd/config.toml`: change the `command = …` line under `[default_session]` to your greeter command. Keep `user = "greeter"`. Put the greeter files somewhere the `greeter` user can read (e.g. `/etc/greetd/quickshell/`).
3. Test it: switch to a second TTY (`Ctrl+Alt+F2`), log in there as a fallback, then run `sudo systemctl restart greetd`.
4. Once it works: `sudo pacman -Rns greetd-tuigreet`. Keep the `[initial_session]` auto-login block; it's independent of the greeter.

---

Back to [the index](README.md)
