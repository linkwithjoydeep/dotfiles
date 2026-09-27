# 3. Install the base system

Runs on the **live ISO**. archinstall equivalent: `minimal_installation()`.

## 3.1 vconsole before pacstrap

**[AI]** `set_vconsole()`. Installing the kernel runs mkinitcpio, which warns if this file is missing.
```bash
mkdir /mnt/etc
```
**Create** `/mnt/etc/vconsole.conf` with:
```ini
KEYMAP=us
FONT=default8x16
```

## 3.2 Install packages

Archinstall also installs in stages like this. Run each command in order; the first one uses `-K` to set up the new system's keyring.

> [NOTE] With no extras chosen, archinstall installs only `base sudo linux-firmware mkinitcpio <kernels> <cpu>-ucode <fs tools e.g. btrfs-progs>` + `zram-generator` (swap is on by default) + the bootloader packages. Everything else below (network, audio, desktop, fonts, even `man`) comes from menu choices: the Desktop/Hyprland profile, the graphics driver and the Applications section, plus the **[CUSTOM]** additions.

### Base system

**[AI]** base, sudo, firmware, mkinitcpio, both kernels, CPU microcode and btrfs tools. Use `intel-ucode` instead of `amd-ucode` on Intel CPUs.
```bash
pacstrap -K /mnt base sudo linux-firmware mkinitcpio linux linux-lts amd-ucode btrfs-progs
```

> [NOTE] `linux-firmware` (the meta package) is kept on purpose. Installing only the split packages for your current hardware (e.g. `linux-firmware-{amdgpu,nvidia,realtek,amd}`) would save ~400 MB, but hardware you add later (new Wi-Fi card, USB dongle, other GPU) might not work until you install its firmware by hand.
> [NOTE] archinstall also adds `sof-firmware` / `alsa-firmware` **only** when it detects hardware that needs them (Intel SOF laptops, some old sound cards). Add them to this command if your machine needs them.

### Swap, bootloader and splash

**[AI]** **[CUSTOM]** plus `systemd-ukify` (UKI builder, see [6.6](06-boot-chain.md#66-build-the-ukis)).
```bash
pacstrap /mnt zram-generator refind efibootmgr plymouth systemd-ukify
```

| Package | Purpose |
|---|---|
| zram-generator | Compressed swap in RAM ([5.3](05-system-basics.md#53-swap-on-zram)) |
| refind / efibootmgr | Boot manager / firmware boot entries ([6.7](06-boot-chain.md#67-refind)) |
| plymouth | Boot splash + graphical LUKS prompt ([6.5](06-boot-chain.md#65-plymouth-theme)) |
| systemd-ukify | systemd's UKI builder. mkinitcpio uses it automatically ([6.6](06-boot-chain.md#66-build-the-ukis)); also used for recovery ([9.1](09-recovery-rollback.md#91-on-disk-recovery-environment)) and snapshot entries ([10.2](10-rollback-addons.md#102-snapshot-boot-entries)). Pulls in python + a few python libs. |

### Graphics driver [NVIDIA]

**[AI]** with a non-mainline kernel (`linux-lts`), archinstall picks the DKMS driver + headers.
**[CUSTOM]** adds `lib32-nvidia-utils` (Steam/Wine) and `mesa` explicitly.
```bash
pacstrap /mnt nvidia-open-dkms dkms linux-headers linux-lts-headers nvidia-utils libva-nvidia-driver lib32-nvidia-utils mesa
```
No NVIDIA GPU? Skip this command and install your GPU's Mesa/Vulkan drivers instead (see [Different hardware](README.md#different-hardware)).

### Network

**[AI]** NetworkManager + wpa_supplicant + the applet (added for desktop profiles).
```bash
pacstrap /mnt networkmanager wpa_supplicant network-manager-applet
```
`network-manager-applet` is optional on Hyprland. See [how it works and how to remove it](appendix-replacing-components.md#network-manager-applet).

### Common desktop tools

**[AI]** **[CUSTOM]** plus `vi`.
```bash
pacstrap /mnt nano vim vi openssh htop wget smartmontools xdg-utils
```

| Package | Purpose |
|---|---|
| nano / vim / vi | Editors (`vi` = classic vi; some tools such as `visudo` default to it) |
| openssh | `ssh` client. `sshd` is **not** enabled (`sudo systemctl enable --now sshd` if needed) |
| htop | Process viewer (btop, installed below, is the prettier alternative) |
| wget | Downloader (curl is in base) |
| smartmontools | `sudo smartctl -a /dev/sda`: SSD/HDD health |
| xdg-utils | `xdg-open`, `xdg-mime`: many apps rely on it. Keep. |

### Hyprland

**[AI]** **[CUSTOM]** `hyprpolkitagent` instead of `polkit-kde-agent`, `nautilus` instead of `dolphin`, `hyprlauncher` instead of `wofi`.
```bash
pacstrap /mnt hyprland xdg-desktop-portal-hyprland uwsm kitty dunst hyprlauncher nautilus qt5-wayland qt6-wayland hyprpolkitagent grim slurp polkit
```

| Package | Purpose |
|---|---|
| hyprland | Compositor |
| xdg-desktop-portal-hyprland | Screen sharing, screenshots via portal, file pickers |
| uwsm | Runs Hyprland as a systemd user session (clean env + shutdown) |
| qt5-wayland / qt6-wayland | Native Wayland for Qt apps (qt6 is needed by Quickshell) |
| kitty | Terminal |
| dunst | Notifications |
| hyprlauncher | App launcher from the Hyprland team; the default Hyprland config binds it to `SUPER + R` ([8.1](08-post-install.md#81-hyprland-default-config)) |
| hyprpolkitagent | Password dialog for privileged GUI actions (enabled in [7.2](07-desktop-services.md#72-hyprland-profile-and-polkit)) |
| nautilus | File manager (point `SUPER + E` at it in [8.1](08-post-install.md#81-hyprland-default-config)) |
| grim / slurp | Screenshot / region select (`grim -g "$(slurp)"`) |
| polkit | Authorization for privileged actions ([7.2](07-desktop-services.md#72-hyprland-profile-and-polkit)) |

Plans to swap some of these for Quickshell components: see [Appendix A](appendix-replacing-components.md#hyprland-packages).

### Greeter

**[CUSTOM]** configured in [7.3](07-desktop-services.md#73-greeter-greetd-and-tuigreet). tuigreet is the login screen after a logout or a Hyprland crash, until a Quickshell greeter replaces it ([Appendix A](appendix-replacing-components.md#greeter)).
```bash
pacstrap /mnt greetd greetd-tuigreet
```

### Applications

**[AI]** bluetooth, pipewire audio, printing (**[CUSTOM]** plus avahi/nss-mdns), power profiles, firewall. Services are enabled in [7.1](07-desktop-services.md#71-applications).
```bash
pacstrap /mnt bluez bluez-utils
pacstrap /mnt pipewire pipewire-alsa pipewire-jack pipewire-pulse gst-plugin-pipewire libpulse wireplumber
pacstrap /mnt cups cups-filters ghostscript system-config-printer cups-pk-helper avahi nss-mdns
pacstrap /mnt power-profiles-daemon ufw
```

| Package | Purpose |
|---|---|
| bluez / bluez-utils | Bluetooth stack / `bluetoothctl` |
| pipewire | Core audio/video stream server (also screen-share video) |
| wireplumber | Session/policy manager: routing, default devices, BT profiles |
| pipewire-pulse | PulseAudio replacement server, so Pulse apps work |
| pipewire-alsa | Routes plain ALSA apps through PipeWire |
| pipewire-jack | JACK replacement for pro-audio / DAWs |
| gst-plugin-pipewire | GStreamer ↔ PipeWire (GTK/GNOME apps, some recorders) |
| libpulse | Pulse client library many apps link to |
| cups | Print server + web UI (http://localhost:631) |
| cups-filters | Converts documents to printer formats; needed for driverless printing |
| ghostscript | PostScript/PDF rasterizer |
| system-config-printer | GUI printer manager ("Print Settings") |
| cups-pk-helper | Lets the GUI do admin actions via polkit |
| avahi / nss-mdns | Network printer discovery (mDNS/DNS-SD) and `.local` name resolution |
| power-profiles-daemon | `powerprofilesctl set performance / balanced / power-saver` (tunes the CPU's pstate driver). Quickshell/waybar can toggle it. |
| ufw | Simple firewall frontend |

Printer vendor drivers are **not** bundled. Modern printers work driverless; see [8.7](08-post-install.md#87-printer-setup).

### Fonts

**[AI]** **[CUSTOM]** plus noto-fonts-extra and JetBrains Mono Nerd.
```bash
pacstrap /mnt noto-fonts noto-fonts-emoji noto-fonts-cjk noto-fonts-extra ttf-liberation ttf-jetbrains-mono-nerd
```

| Package | Purpose |
|---|---|
| noto-fonts (+emoji, cjk, extra) | Coverage for almost every script + color emoji |
| ttf-liberation | Metric-compatible Arial/Times/Courier: fixes layouts in websites, Steam, Proton games, office docs |
| ttf-jetbrains-mono-nerd | Terminal/coding font with Nerd icons (for Quickshell/bar icons) |

### Snapshots

**[AI]** snapper. **[CUSTOM]** plus snap-pac and compsize. Configured in [chapter 4](04-snapper-fstab.md).
```bash
pacstrap /mnt snapper snap-pac compsize
```

| Package | Purpose |
|---|---|
| snapper | Snapshot manager |
| snap-pac | Automatic snapper pre/post snapshots around every pacman transaction |
| compsize | Shows btrfs compression ratio ([8.9](08-post-install.md#89-btrfs-cheat-sheet)) |

### Additional packages

**[CUSTOM]**
```bash
pacstrap /mnt git base-devel man-db man-pages zsh firefox fastfetch btop reflector pacman-contrib sbctl
```

| Package | Purpose |
|---|---|
| git / base-devel | Needed to build AUR packages ([8.5](08-post-install.md#85-aur-helper-paru)) |
| man-db / man-pages | `man` pages |
| zsh | Login shell for your user ([5.5](05-system-basics.md#55-users-and-sudo)) |
| firefox, fastfetch, btop | Browser, system info, process viewer |
| reflector | Mirror ranking, manual use only ([3.4](#34-mirrorlist-on-the-new-system)) |
| pacman-contrib | `paccache` (cache cleanup, timer enabled in [7.4](07-desktop-services.md#74-maintenance-timers)), `checkupdates` (safe update check, ideal for a Quickshell update widget), `pactree`, `pacdiff` (merge `.pacnew` files) |
| sbctl | Secure Boot key management ([8.3](08-post-install.md#83-secure-boot-with-sbctl)) |

## 3.3 pacman.conf on the new system

**[AI]** `pacman_conf.persist()` + `configure()`.

**Edit** `/mnt/etc/pacman.conf`. In the `[options]` section:
- Uncomment `Color` **[AI]**, and add a new line `ILoveCandy` right under it **[CUSTOM]**
- Uncomment `ParallelDownloads` and set `ParallelDownloads = 10` **[AI]** (default 5)
- Uncomment `VerbosePkgLists` **[CUSTOM]**

Near the bottom, uncomment multilib **[AI]**:
```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

What these do:
- `ParallelDownloads = 10`: downloads 10 packages at once. Beyond ~10 you gain little, and some mirrors throttle you.
- `VerbosePkgLists`: before an upgrade, shows a table of **old version → new version** and size per package.
- `ILoveCandy`: purely cosmetic; the progress bar becomes a Pac-Man eating dots.

## 3.4 Mirrorlist on the new system

**[AI]** `set_mirrors(on_target=True)`. `pacstrap` already copied the ISO mirrorlist (with your Worldwide lines from [1.5](01-live-environment.md#15-mirrors-worldwide-first-reflector-fallback)) to the new system. Nothing to do.

> [NOTE] **Don't enable `reflector.timer`**: it would overwrite the whole list and drop the Worldwide lines.
> To refresh the fallback mirrors later, rerun the same `reflector … --save /etc/pacman.d/mirrorlist` command with `sudo`, then add the Worldwide lines back at the top ([1.5](01-live-environment.md#15-mirrors-worldwide-first-reflector-fallback)).

---

Next: [4. Snapper and fstab](04-snapper-fstab.md)
