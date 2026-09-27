# 1. Prepare the live environment

Everything in this chapter runs on the **booted Arch ISO**.

## 1.1 Keyboard and console font

**[AI]** The ISO default is already `us` / `default8x16`. Nothing to do.

```bash
# double the current font on HiDPI displays
setfont -d
```

## 1.2 Confirm UEFI boot

This must print `64`:
```bash
cat /sys/firmware/efi/fw_platform_size
```

## 1.3 Connect to the network

Ethernet works automatically. For Wi-Fi only, run `iwctl`, then type `station wlan0 connect "<SSID>"`, then `exit`.
```bash
ping -c3 archlinux.org
```

## 1.4 Check time and keyring

**[AI]** archinstall's `sanity_check()` waits for these:
```bash
timedatectl                              # should say "System clock synchronized: yes"
pacman -Sy archlinux-keyring             # only needed if the ISO is old
```

## 1.5 Mirrors: Worldwide first, reflector fallback

**[CUSTOM]** Archinstall writes the "Worldwide" region mirrors sorted by speed. We put the Worldwide CDN mirrors first and reflector's fastest local mirrors after them.

> [NOTE] The ISO runs its own `reflector.service` once at boot and overwrites the mirrorlist when it finishes. Wait until `systemctl is-active reflector.service` prints `inactive` before doing this step, so your edits aren't overwritten.

1. Let reflector write the local mirrors (replace `India` with your country):
   ```bash
   reflector --country India --protocol https --latest 20 --sort rate --number 5 --save /etc/pacman.d/mirrorlist
   ```
2. **Edit** `/etc/pacman.d/mirrorlist` and add these lines at the **top** of the file:
   ```ini
   ## Worldwide (preferred)
   Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch
   Server = https://fastly.mirror.pkgbuild.com/$repo/os/$arch
   ## reflector: fastest local mirrors (fallback)
   ```

`pacstrap` copies this file to the new system later ([3.4](03-base-install.md#34-mirrorlist-on-the-new-system)).

## 1.6 Enable multilib and parallel downloads on the ISO

**[AI]** archinstall enables optional repos on the host before pacstrap.

**Edit** `/etc/pacman.conf`:
- Uncomment `ParallelDownloads` and set it to `ParallelDownloads = 10`.
- Near the bottom, uncomment the two multilib lines (needed for 32-bit packages such as `lib32-nvidia-utils`) so they read:
  ```ini
  [multilib]
  Include = /etc/pacman.d/mirrorlist
  ```

Then refresh:
```bash
pacman -Sy
```

---

Next: [2. Partition, encrypt and format the disk](02-disk-setup.md)
