# 5. System basics

Enter the new system:
```bash
arch-chroot /mnt
```
Everything in chapters 5, 6 and 7 runs **inside the chroot**, until you exit in [7.6](07-desktop-services.md#76-exit-and-reboot).

## 5.1 Hostname and locale

**[AI]** `set_hostname()`, `set_locale()`.

1. **Create** `/etc/hostname` with:
   ```
   joy-arch
   ```
2. **Edit** `/etc/locale.gen`: uncomment the line `#en_US.UTF-8 UTF-8`.
3. Generate locales:
   ```bash
   locale-gen
   ```
4. **Create** `/etc/locale.conf` with:
   ```ini
   LANG=en_US.UTF-8
   ```
> [NOTE] archinstall also runs `localectl set-keymap us` inside a booted container. That only matters for X11. `vconsole.conf` ([3.1](03-base-install.md#31-vconsole-before-pacstrap)) already covers the console, and Hyprland sets its keyboard layout in its own config.

## 5.2 Timezone and NTP

**[AI]** `set_timezone()`, `activate_time_synchronization()`.
```bash
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
systemctl enable systemd-timesyncd
```
`hwclock --systohc` is **[CUSTOM]** (an Arch Wiki step). It writes `/etc/adjtime` with the hardware clock in UTC.

> [NOTE] **Dual-booting Windows:** Windows keeps the hardware clock in local time, Linux in UTC, so one of them will show the time off by your UTC offset.
> Fix it once on the Windows side (Command Prompt as admin):
> `reg add "HKLM\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /d 1 /t REG_DWORD /f`

## 5.3 Swap on zram

**[AI]** `setup_swap()`.

**Create** `/etc/systemd/zram-generator.conf` with:
```ini
[zram0]
compression-algorithm = zstd
```
```bash
systemctl enable systemd-zram-setup@zram0.service
```
> [NOTE] This `enable` is what archinstall runs. It may print a warning that the unit has no installation config; that's harmless, because zram-generator sets up `zram0` at boot on its own from the config file.
> [NOTE] Default size is `min(RAM/2, 4 GiB)`. To use half of RAM with no 4 GiB cap, add the line `zram-size = ram / 2`.
> **[AI]** `zswap.enabled=0` goes on the kernel cmdline ([6.3](06-boot-chain.md#63-kernel-command-line)) so zswap doesn't double-compress in front of zram.

## 5.4 Network

**[AI]** `install_network_config()`, NetworkManager branch.
```bash
systemctl enable NetworkManager.service
```
Handles Ethernet and Wi-Fi together, with automatic failover. Use `nmtui` (menu interface) or `nmcli` in the terminal, e.g. `nmcli device wifi connect "SSID" --ask`. Saved networks reconnect automatically. A GUI network menu can come later from a Quickshell widget ([Appendix A](appendix-replacing-components.md#network-gui)).

## 5.5 Users and sudo

**[AI]** `create_users()`. **[CUSTOM]** wheel drop-in + zsh.

1. Root password **[AI]**:
   ```bash
   passwd
   ```
2. Create your user in the `wheel` group with zsh as the shell (**[AI]** `useradd -m -G wheel`, **[CUSTOM]** `-s /usr/bin/zsh`):
   ```bash
   useradd -m -G wheel -s /usr/bin/zsh joy
   passwd joy
   ```
3. **[CUSTOM]** Allow the whole `wheel` group to use sudo, the Arch Wiki way (archinstall writes a per-user `00_<username>` file instead). `visudo` checks the syntax before saving (it opens `$EDITOR`, `vi` by default; prefix with `EDITOR=<your editor>` to change it):
   ```bash
   visudo -f /etc/sudoers.d/10-wheel
   ```
   Add this single line, then save and exit:
   ```
   %wheel ALL=(ALL:ALL) ALL
   ```

---

Next: [6. Initramfs, UKIs and bootloader](06-boot-chain.md)
