# 7. Desktop, services and first boot

Still **inside the chroot**, until [7.6](#76-exit-and-reboot).

## 7.1 Applications

**[AI]** `ApplicationHandler.install_applications()`. Packages were installed in [3.2](03-base-install.md#applications).

### Bluetooth

**[AI]**
```bash
systemctl enable bluetooth.service
```
> [NOTE] **`AutoEnable`** is a `/etc/bluetooth/main.conf` option that powers the adapter on at boot. It's **not** set by archinstall, and it's **already the default** since BlueZ 5.65, so no action is needed. Most USB/combo adapters (via `btusb`, firmware in `linux-firmware`) work with the default setup. If pairing breaks after suspend: `sudo modprobe -r btusb` then `sudo modprobe btusb`.

### Audio

**[AI]** Nothing to enable.

> [NOTE] archinstall symlinks `pipewire-pulse.{service,socket}` into `~<user>/.config/systemd/user/default.target.wants/`. That's redundant. Arch's pipewire packages already enable their user units **globally** on install (links in `/etc/systemd/user/`). "Global" means the enable applies to **every** user's `systemd --user` instance, now and in the future (`systemctl --global enable X`). Per-user `systemctl --user enable` only affects one user. Check after boot with `systemctl --user status pipewire pipewire-pulse wireplumber`.

### Printing

**[AI]** cups. **[CUSTOM]** plus avahi.
```bash
systemctl enable cups.service
systemctl enable avahi-daemon.service
```
**Edit** `/etc/nsswitch.conf`. On the line starting with `hosts:`, insert `mdns_minimal [NOTFOUND=return]` right after `mymachines`, so it reads:
```
hosts: mymachines mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns
```
This lets the system resolve `*.local` names, which network printers use. Adding the printer itself happens after first boot ([8.7](08-post-install.md#87-printer-setup)).

### Power profiles

**[AI]**
```bash
systemctl enable power-profiles-daemon.service
```

### Firewall

**[AI]**
```bash
systemctl enable ufw.service
```
archinstall also edits `ENABLED=yes` into `/etc/ufw/ufw.conf`, because the `ufw` command can't run inside a chroot. We use the official `sudo ufw enable` after first boot instead ([8.2](08-post-install.md#82-firewall-rules)). The defaults are already deny incoming / allow outgoing.

## 7.2 Hyprland profile and polkit

**[AI]** `profile_handler.install_profile_config()`. Packages were installed in [3.2](03-base-install.md#hyprland).

**Seat access = polkit [AI]:** archinstall runs `systemctl enable polkit`, but polkit is started on demand, so there's nothing to enable.

Background: Hyprland needs access to the "seat" (GPU, keyboard, mouse). With `polkit`, **systemd-logind** hands that access to your session and polkit decides who may do privileged things (mount disks, change network settings, power off). `seatd` is the alternative for systems without logind. On systemd Arch, polkit is the natural choice.

**Polkit agent [CUSTOM]:** polkit needs an *agent* in your session to show the password dialog; without one, GUI actions that need a password fail silently. Enable `hyprpolkitagent` for every user's graphical session (the same "global" mechanism as the audio note in [7.1](#audio)):
```bash
systemctl --global enable hyprpolkitagent.service
```
It starts with the uwsm-managed Hyprland session (`graphical-session.target`). Only one polkit agent may run at a time; to replace it later, see [Appendix A](appendix-replacing-components.md#hyprland-packages).

## 7.3 Greeter: greetd and tuigreet

**[CUSTOM]**

**Edit** `/etc/greetd/config.toml`. Under `[default_session]`, change the `command = ...` line to:
```toml
command = "tuigreet --time --remember --remember-session --asterisks --cmd 'uwsm start hyprland.desktop'"
```
Leave `user = "greeter"` and `vt = 1` as they are. With auto-login (below), you only see tuigreet after logging out or if Hyprland crashes: a convenient fallback until a Quickshell greeter exists.

**[CUSTOM] Auto-login after disk unlock.** You already typed the disk password at the Plymouth prompt, so skip the second password prompt: add this block at the end of the same file (use your username):
```toml
[initial_session]
command = "uwsm start hyprland.desktop"
user = "joy"
```
Then:
```bash
systemctl enable greetd.service
```

How it works and why it's safe:
- `initial_session` runs **once per boot**: greetd starts that user's session without asking for a password. After you log out (or the session crashes), you get the tuigreet login.
- Your user password is still needed for `sudo`, tuigreet and the lock screen.
- Only root can edit `/etc/greetd/config.toml`, and while the machine is off it sits on the encrypted disk. So the **disk password is the gate** for the desktop.
- ⚠️ Because of that, **never combine auto-login with TPM auto-unlock** ([8.4](08-post-install.md#84-recovery-key-and-optional-tpm2-unlock)): anyone could power the machine on and land on your desktop.
- Lock the screen when you step away (e.g. with `hyprlock`, not installed by this guide); otherwise a running session is open to anyone at the keyboard.

To replace tuigreet with a Quickshell greeter later, see [Appendix A](appendix-replacing-components.md#greeter).

## 7.4 Maintenance timers

**[AI]** / **[CUSTOM]**
```bash
systemctl enable snapper-timeline.timer snapper-cleanup.timer
systemctl enable btrfs-scrub@-.timer
systemctl enable paccache.timer
```
| Timer | Purpose |
|---|---|
| `snapper-timeline` / `snapper-cleanup` **[AI]** | Hourly snapshots + pruning to the limits from [4.2](04-snapper-fstab.md#42-snapshot-retention-and-access-for-wheel) |
| `btrfs-scrub@-` **[CUSTOM]** | Monthly checksum verification of `/` (`-` = the root path) |
| `paccache` **[CUSTOM]** | Weekly pacman cache cleanup, keeping the last 3 versions of each package |

> [NOTE] `fstrim.timer` is deliberately **not** enabled: btrfs already trims continuously with `discard=async` ([2.5](02-disk-setup.md#25-mount-everything)).

## 7.5 Final check before reboot

```bash
ls /efi/EFI/Linux /efi/EFI/refind /efi/EFI/BOOT
cat /etc/kernel/cmdline
efibootmgr
```
You should see 4 UKIs, rEFInd in both folders, a correct cmdline, and "rEFInd Boot Manager" in the boot list.

## 7.6 Exit and reboot

```bash
exit
umount -R /mnt
cryptsetup close root
reboot
```
Remove the USB. rEFInd should appear. Pick `arch-linux.efi`, enter the disk password at the Plymouth prompt, and Hyprland starts without a second login.

Default Hyprland keys to get around before you customise anything ([8.1](08-post-install.md#81-hyprland-default-config)):

| Key | Does |
|---|---|
| `SUPER + Q` | Open a terminal (kitty) |
| `SUPER + C` | Close the focused window |
| `SUPER + M` | Exit Hyprland, back to the tuigreet login |
| `Ctrl + Alt + F2` … `F6` | Text console login, if Hyprland is unusable (`Ctrl + Alt + F1` returns) |

`SUPER` is the Windows key (Cmd on a Mac keyboard).

---

Next: [8. Post-install](08-post-install.md)
