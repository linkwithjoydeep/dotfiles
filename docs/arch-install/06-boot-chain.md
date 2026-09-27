# 6. Initramfs, UKIs and bootloader

Still **inside the chroot**.

The boot chain is: firmware → **rEFInd** (on the ESP) → a **UKI** (kernel + initramfs + cmdline in one `.efi` file, also on the ESP) → the initramfs unlocks LUKS and mounts `@` as `/`.

## 6.1 mkinitcpio: systemd initramfs and early KMS

**[CUSTOM]** systemd-based initramfs + early NVIDIA modules.

**Edit** `/etc/mkinitcpio.conf`:
- **[NVIDIA]** Find the line `MODULES=()` and change it to:
  ```ini
  MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
  ```
  Without an NVIDIA GPU, leave `MODULES=()` as it is.
- Find the **uncommented** `HOOKS=(...)` line (not the commented examples above it) and replace it with:
  ```ini
  HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block plymouth sd-encrypt filesystems fsck)
  ```

**Why switch from busybox/udev (archinstall's default without FIDO2) to systemd:**
- **TPM2 / FIDO2 unlocking only works with `sd-encrypt`**. This guide unlocks with a password, but `sd-encrypt` keeps TPM2/FIDO2 available as an option ([8.4](08-post-install.md#84-recovery-key-and-optional-tpm2-unlock)). The old `encrypt` hook can only take a password or keyfile.
- The unlock is configured with `rd.luks.*` kernel params ([6.3](#63-kernel-command-line)) and LUKS2 tokens, so after `systemd-cryptenroll` a TPM keyslot is picked up automatically.
- Plymouth integrates better (password prompt via `systemd-ask-password`).
- Same init system in initramfs and in the real system, so there's one set of logs (`journalctl -b` shows early boot too).
- Archinstall itself switches to this when you pick a FIDO2 key. It only keeps busybox "for stability", which is no longer a real concern.

**MODULES [NVIDIA]**

| Module | Purpose |
|---|---|
| `nvidia` | Core NVIDIA kernel driver |
| `nvidia_modeset` | Display/mode-setting part of the driver |
| `nvidia_uvm` | Unified memory: CUDA, NVENC/NVDEC, some Vulkan paths |
| `nvidia_drm` | DRM/KMS interface. With it loaded early, Plymouth and the LUKS prompt render on monitors connected to the NVIDIA card. `modeset=1` + `fbdev=1` are defaults on current drivers. |

Loading these early is the Hyprland wiki's recommendation (Early KMS). Nouveau is already blacklisted by `/usr/lib/modprobe.d/nvidia-utils.conf`. Because the modules now live *inside* the UKI, a driver update needs a UKI rebuild ([6.2](#62-nvidia-pacman-hook)).

**HOOKS** (order matters)

| Hook | Purpose |
|---|---|
| `base` | Basic filesystem layout/busybox tools for the initramfs |
| `systemd` | Uses systemd as PID 1 in the initramfs (replaces `udev`) |
| `autodetect` | Shrinks the image to modules your hardware needs (the fallback UKI skips this) |
| `microcode` | Embeds the CPU microcode (`amd-ucode` / `intel-ucode`) so it loads first |
| `modconf` | Includes `/etc/modprobe.d` + `/usr/lib/modprobe.d` (nouveau blacklist, NVreg options) |
| `kms` | Adds GPU KMS modules (e.g. `amdgpu` / `i915` for an integrated GPU) |
| `keyboard` | USB/HID keyboard modules so you can type the LUKS password |
| `sd-vconsole` | Keymap + console font from `/etc/vconsole.conf` (replaces `keymap consolefont`) |
| `block` | Storage controller modules (SATA/NVMe/USB) |
| `plymouth` | Boot splash + graphical password prompt. **Must come before `sd-encrypt`.** [AI] puts it there too. |
| `sd-encrypt` | Unlocks LUKS using `rd.luks.name=` (password / TPM2 / FIDO2) |
| `filesystems` | btrfs (and other fs) modules |
| `fsck` | fsck helper (no-op for btrfs, harmless) |

> [NOTE] The optional snapshot boot entries ([10.2](10-rollback-addons.md#102-snapshot-boot-entries)) later add `sd-volatile` after `sd-encrypt`.

## 6.2 NVIDIA pacman hook

**[CUSTOM]** **[NVIDIA]** Rebuild the UKIs when the NVIDIA driver updates. The modules are inside the UKI ([6.1](#61-mkinitcpio-systemd-initramfs-and-early-kms)), so a driver update without a rebuild would leave a kernel/module version mismatch.

```bash
mkdir /etc/pacman.d/hooks
```
**Create** `/etc/pacman.d/hooks/nvidia.hook` with:
```ini
[Trigger]
Operation = Install
Operation = Upgrade
Operation = Remove
Type = Package
Target = nvidia-open-dkms
Target = linux
Target = linux-lts

[Action]
Description = Rebuilding UKIs for NVIDIA module update...
Depends = mkinitcpio
When = PostTransaction
NeedsTargets
Exec = /bin/sh -c 'while read -r trg; do case $trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'
```
The `Exec` line means: if a kernel was also updated in this transaction, skip, because mkinitcpio's own hook already rebuilds. Otherwise run `mkinitcpio -P`.

Without an NVIDIA GPU, skip this step, but still run `mkdir /etc/pacman.d/hooks`: the rEFInd hook in [6.7](#67-refind) goes in the same folder.

## 6.3 Kernel command line

**[AI]** `_get_kernel_params()`. **[CUSTOM]** `rd.luks` syntax.

You need the **LUKS UUID** of `/dev/sda2`. To avoid typing it, write it straight into the file first:
```bash
blkid -s UUID -o value /dev/sda2 > /etc/kernel/cmdline
```
**Edit** `/etc/kernel/cmdline`. It contains only the UUID. Turn it into this single line, keeping your UUID where `<UUID>` is:
```
rd.luks.name=<UUID>=root root=/dev/mapper/root rootflags=subvol=@ rw rootfstype=btrfs zswap.enabled=0 quiet splash
```
- archinstall (busybox) would use `cryptdevice=PARTUUID=…:root`. `sd-encrypt` needs `rd.luks.name=<LUKS UUID>=root`.
- `zswap.enabled=0`: see [5.3](05-system-basics.md#53-swap-on-zram).
- `quiet splash` are added by archinstall's Plymouth step.
- No TPM or discard options are needed here: TPM tokens, if you ever enroll one, are tried automatically ([8.4](08-post-install.md#84-recovery-key-and-optional-tpm2-unlock)) and TRIM is stored in the LUKS header ([2.3](02-disk-setup.md#23-create-the-luks2-container)).
- Optional for an even cleaner boot: append `loglevel=3 rd.udev.log_level=3 vt.global_cursor_default=0`.
- Keep `rootflags=subvol=@` followed by a space (i.e. not at the very end of the line). The optional snapshot entries script ([10.2](10-rollback-addons.md#102-snapshot-boot-entries)) looks for `rootflags=subvol=@ ` to rewrite it.

## 6.4 UKI presets

**[AI]** `_config_uki()`. Change the kernel presets so they build UKIs into `/efi/EFI/Linux` instead of plain initramfs images.

**Edit** `/etc/mkinitcpio.d/linux.preset` and replace its content with:
```ini
# mkinitcpio preset file for the 'linux' package (UKI mode)
ALL_kver="/boot/vmlinuz-linux"

PRESETS=('default' 'fallback')

default_uki="/efi/EFI/Linux/arch-linux.efi"
default_options="--splash /usr/share/systemd/bootctl/splash-arch.bmp"

fallback_uki="/efi/EFI/Linux/arch-linux-fallback.efi"
fallback_options="-S autodetect"
```

**Edit** `/etc/mkinitcpio.d/linux-lts.preset` the same way, with `linux-lts` names:
```ini
# mkinitcpio preset file for the 'linux-lts' package (UKI mode)
ALL_kver="/boot/vmlinuz-linux-lts"

PRESETS=('default' 'fallback')

default_uki="/efi/EFI/Linux/arch-linux-lts.efi"
default_options="--splash /usr/share/systemd/bootctl/splash-arch.bmp"

fallback_uki="/efi/EFI/Linux/arch-linux-lts-fallback.efi"
fallback_options="-S autodetect"
```

Create the UKI folder and remove the old initramfs images **[AI]**:
```bash
mkdir -p /efi/EFI/Linux
rm /boot/initramfs-*.img
```
> [CUSTOM] Fallback UKIs are enabled. Without `autodetect` they contain all modules, which makes them the rescue option if hardware changes. Expect roughly 4 UKIs × 100–250 MB (NVIDIA GSP firmware is large), which fits comfortably in the 5 GiB ESP.

## 6.5 Plymouth theme

**[AI]** `_install_plymouth()`.
```bash
plymouth-set-default-theme spinner
```
`spinner` is a dark background with a small minimal spinner.

> [NOTE] Change the theme later:
> ```bash
> plymouth-set-default-theme -l             # list installed themes
> sudo plymouth-set-default-theme -R bgrt   # -R also rebuilds the UKIs
> ```
> Custom themes go in `/usr/share/plymouth/themes/<name>/` (the AUR has many `plymouth-theme-*`). To preview without rebooting, run these one at a time:
> `sudo plymouthd`, then `sudo plymouth --show-splash`, wait a few seconds, then `sudo plymouth quit`.

## 6.6 Build the UKIs

```bash
mkinitcpio -P
ls -lh /efi/EFI/Linux/
```
You should see `arch-linux.efi`, `arch-linux-fallback.efi`, `arch-linux-lts.efi` and `arch-linux-lts-fallback.efi`.

> [CUSTOM] **UKIs are assembled with `ukify`.** Because `systemd-ukify` is installed, mkinitcpio automatically uses it instead of its built-in `objcopy` method (the output shows `Using ukify to build UKI`). The initramfs, hooks and pacman triggers are exactly the same; only the final "glue kernel + initramfs + cmdline into one .efi" step changes.
> Why: `ukify` is systemd's own UKI tool. It handles the section layout itself, adds the standard sections (`.osrel`, `.uname`, `.sbat`), and supports signed TPM PCR policies (`systemd-measure`) if you ever want stronger TPM binding than PCR 7. Recovery ([9.1](09-recovery-rollback.md#91-on-disk-recovery-environment)) and snapshot entries ([10.2](10-rollback-addons.md#102-snapshot-boot-entries)) use it too.
> To go back to `objcopy`, add `--no-ukify` to the `default_options` and `fallback_options` lines in the presets ([6.4](#64-uki-presets)).

## 6.7 rEFInd

**[AI]** installs refind + runs `refind-install`. **[CUSTOM]** manual install to both locations.

Archinstall runs `refind-install` and writes `/boot/refind_linux.conf`. With UKIs that file is never used, because rEFInd auto-detects the `.efi` files in `EFI/Linux`. We install manually so that the NVRAM entry **and** the removable fallback path are both set up, and nothing depends on how `refind-install` guesses the ESP location.

1. Copy rEFInd to the ESP:
   ```bash
   mkdir -p /efi/EFI/refind/themes
   cp /usr/share/refind/refind_x64.efi /efi/EFI/refind/
   cp -r /usr/share/refind/icons /efi/EFI/refind/
   cp /usr/share/refind/refind.conf-sample /efi/EFI/refind/refind.conf
   ```
2. Add the firmware (NVRAM) boot entry:
   ```bash
   efibootmgr --create --disk /dev/sda --part 1 --loader '\EFI\refind\refind_x64.efi' --label 'rEFInd Boot Manager' --unicode
   ```
3. **Create** `/usr/local/bin/refind-sync` with the content below. It keeps the removable copy (`EFI/BOOT`) identical to `EFI/refind`, updates the rEFInd binary, and re-signs for Secure Boot once that's set up ([8.3](08-post-install.md#83-secure-boot-with-sbctl)).
   ```sh
   #!/bin/sh
   # EFI/refind is the main copy (edit refind.conf/themes there).
   # EFI/BOOT is a mirror of it, for firmware that ignores NVRAM entries.
   set -e

   # 1. Update the rEFInd binary + icons from the installed package
   cp /usr/share/refind/refind_x64.efi /efi/EFI/refind/refind_x64.efi
   cp -r /usr/share/refind/icons /efi/EFI/refind/

   # 2. Rebuild the removable copy
   rm -rf /efi/EFI/BOOT
   cp -r /efi/EFI/refind /efi/EFI/BOOT
   mv /efi/EFI/BOOT/refind_x64.efi /efi/EFI/BOOT/BOOTX64.EFI

   # 3. Re-sign for Secure Boot (only once sbctl keys are enrolled)
   if sbctl status 2>/dev/null | grep -q 'Setup Mode:.*Disabled'; then
       sbctl sign-all
   fi
   ```
   Make it executable and run it once:
   ```bash
   chmod +x /usr/local/bin/refind-sync
   refind-sync
   ```
4. **[AI]** pacman hook (archinstall's `99-refind.hook`, pointed at our script). **Create** `/etc/pacman.d/hooks/99-refind.hook` with:
   ```ini
   [Trigger]
   Operation = Install
   Operation = Upgrade
   Type = Package
   Target = refind

   [Action]
   Description = Updating rEFInd on ESP (NVRAM + removable path)
   When = PostTransaction
   Exec = /usr/local/bin/refind-sync
   ```

> [NOTE] After editing `/efi/EFI/refind/refind.conf` or adding a theme, always run `sudo refind-sync`.
> Theme: put it in `/efi/EFI/refind/themes/<name>/` and add `include themes/<name>/theme.conf` at the end of `refind.conf`.
> Useful `refind.conf` options: `timeout 5`, `default_selection "arch-linux.efi"`, `hideui singleuser,hints,arrows`. (If you later set up the snapshot submenu in [10.2](10-rollback-addons.md#102-snapshot-boot-entries), it sets its own `default_selection`; keep only one.)

## 6.8 Windows boot entry

**[OPTIONAL]** Dual boot only. **[CUSTOM]** chainload the Windows Boot Manager.

rEFInd usually auto-detects Windows. An explicit entry is more reliable, lets you control the name, icon and order, and survives changes to scan settings. This assumes Windows is on **another disk with its own ESP** (not on `/dev/sda1`); the commands use `/dev/nvme0n1p1` as that ESP.

**1. Find the Windows ESP**
```bash
lsblk -o NAME,SIZE,FSTYPE,PARTTYPENAME,PARTUUID
```
On the Windows disk, look for a `vfat` partition whose PARTTYPENAME is **EFI System** (typically 100–300 MB, e.g. `nvme0n1p1`). Use that name in the commands below.

Confirm the Windows loader is on it (the mount is read-only, so nothing changes):
```bash
mount --mkdir -o ro /dev/nvme0n1p1 /mnt/winesp
ls /mnt/winesp/EFI/Microsoft/Boot/bootmgfw.efi
umount /mnt/winesp
```
If `ls` prints the path back, it's the right partition.

**2. Add the entry to rEFInd**

Write the partition's PARTUUID to the end of the config, so you don't have to type it:
```bash
lsblk -no PARTUUID /dev/nvme0n1p1 >> /efi/EFI/refind/refind.conf
```
**Edit** `/efi/EFI/refind/refind.conf`. At the very end, the PARTUUID is now the last line. Turn it into this block, putting your PARTUUID where `<PARTUUID>` is (it appears twice):
```
# --- Windows (chainload from the Windows disk's ESP) ---
menuentry "Windows 11" {
    volume   <PARTUUID>
    loader   /EFI/Microsoft/Boot/bootmgfw.efi
    icon     /EFI/refind/icons/os_win8.png
}
# Hide the auto-detected duplicate. Manual entries are not affected.
dont_scan_volumes <PARTUUID>
```

Then sync:
```bash
refind-sync
```
- `volume` accepts the partition GUID (PARTUUID), so the entry doesn't depend on disk order or device naming.
- `dont_scan_volumes` is optional. If Windows ever disappears from the menu, delete that line and run `refind-sync`. Auto-detection then brings it back.
- Test from the rEFInd menu after the first boot.

> [NOTE] **Secure Boot + Windows:** `bootmgfw.efi` is signed by Microsoft, so chainloading works with Secure Boot on **as long as you enrolled with `sbctl enroll-keys -m`** ([8.3](08-post-install.md#83-secure-boot-with-sbctl)).
> **BitLocker:** if Windows uses BitLocker (or "Device Encryption"), changing Secure Boot keys can trigger a BitLocker recovery prompt on the next Windows boot. Get the recovery key first (Windows: `manage-bde -protectors -get C:`, or https://account.microsoft.com/devices/recoverykey).
> **Windows updates** sometimes move "Windows Boot Manager" to the top of the firmware boot order. If rEFInd stops appearing, pick it from the firmware boot menu, then fix the order with `sudo efibootmgr -o <rEFInd number>,<others…>` (plain `efibootmgr` lists the numbers).

---

Next: [7. Desktop, services and first boot](07-desktop-services.md)
