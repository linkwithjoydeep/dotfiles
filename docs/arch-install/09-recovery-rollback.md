# 9. Recovery and rollback

## 9.1 On-disk recovery environment

**[OPTIONAL]** Recommended: it's what you boot when the installed system doesn't, and it's used by [9.2 Method B](#method-b-from-the-recovery-entry-or-a-usb-iso).

**Goal:** a "boot the Arch ISO" entry in rEFInd **and** in the firmware's own boot menu, with no USB stick and no ISO file kept on disk. The firmware entry still works if rEFInd itself is broken (e.g. a bad rEFInd update or a damaged `refind.conf`).

**How it works:**
- The official ISO's initramfs (the `archiso` hook) doesn't need the ISO itself. It finds the folder holding its root filesystem image by the partition's UUID (`archisosearchuuid=`) and a folder name (`archisobasedir=`).
- So we copy just **three things** from the ISO:
  - the kernel (`vmlinuz-linux`) and initramfs (`initramfs-linux.img`, which already includes microcode), wrapped into one **recovery UKI**;
  - the **root filesystem image** folder `arch/x86_64/` (`airootfs.sfs` + checksum/signature files), copied to the ESP. This is the live system itself, ~1.1 GB, so it can't be skipped.
- The ISO file is deleted afterwards.

**ESP layout:**
```
/efi/EFI/recovery/archiso-recovery.efi   ← recovery UKI (kernel + initramfs + cmdline)
/efi/recovery/x86_64/airootfs.sfs         ← live root filesystem (~1.1 GB)
/efi/recovery/x86_64/airootfs.sha512      ← checksum (verified at boot with checksum=y)
```
The live system is copied to RAM at boot (`copytoram` is automatic when there's enough RAM), so the ESP isn't kept busy.

> **Secure Boot: the recovery UKI stays UNSIGNED, on purpose.**
> - The archiso logs you in as root automatically. With password-only unlock (this guide's default) that can't open the disk, but keeping it unsigned stays safe if you ever enable the optional TPM unlock ([8.4](08-post-install.md#84-recovery-key-and-optional-tpm2-unlock)): TPM unlock is bound to PCR 7 (Secure Boot state with *your* keys), so a recovery UKI signed with your keys would let anyone at the keyboard boot it and have the TPM unlock the disk.
> - Unsigned, it simply refuses to start while Secure Boot is on. To use it, you turn Secure Boot **off** in the firmware and type the LUKS password yourself (with Secure Boot off, PCR 7 changes, so a TPM would refuse anyway). Fully safe.
> - **Never** run `sbctl sign` on `archiso-recovery.efi`. `sbctl verify` will list it as unsigned; that's expected.
> - Set a **firmware (BIOS) admin password**, so nobody else can turn Secure Boot off.

### Setup (and refresh: repeat the same steps)

1. `ukify` is already installed (`systemd-ukify`, [3.2](03-base-install.md#swap-bootloader-and-splash)).
2. Download the latest ISO and its signature to a temporary folder:
   ```bash
   mkdir /tmp/recovery
   cd /tmp/recovery
   curl -LO https://geo.mirror.pkgbuild.com/iso/latest/archlinux-x86_64.iso
   curl -LO https://geo.mirror.pkgbuild.com/iso/latest/archlinux-x86_64.iso.sig
   ```
3. Verify it's genuine. The output must say `Good signature` from an Arch release engineer:
   ```bash
   pacman-key -v archlinux-x86_64.iso.sig
   ```
4. Extract only what we need:
   ```bash
   bsdtar -xf archlinux-x86_64.iso arch/boot/x86_64/vmlinuz-linux arch/boot/x86_64/initramfs-linux.img arch/x86_64
   ls -lh arch/boot/x86_64 arch/x86_64
   ```
   You should see `vmlinuz-linux` and `initramfs-linux.img`, and `airootfs.sfs`, `airootfs.sha512` and signature files.
5. Refresh: remove the previous recovery files, then check space (you need ~1.5 GB free):
   ```bash
   sudo rm -rf /efi/recovery /efi/EFI/recovery
   df -h /efi
   ```
6. Copy the live root filesystem to the ESP:
   ```bash
   sudo mkdir -p /efi/recovery /efi/EFI/recovery
   sudo cp -r arch/x86_64 /efi/recovery/
   ```
7. Get the ESP's filesystem UUID. It looks like `ABCD-1234`:
   ```bash
   blkid -s UUID -o value /dev/sda1
   ```
8. Build the recovery UKI, replacing `ABCD-1234` with your UUID:
   ```bash
   sudo ukify build \
     --linux arch/boot/x86_64/vmlinuz-linux \
     --initrd arch/boot/x86_64/initramfs-linux.img \
     --cmdline "archisobasedir=recovery archisosearchuuid=ABCD-1234 checksum=y" \
     --output /efi/EFI/recovery/archiso-recovery.efi
   ```
   | Parameter | Meaning |
   |---|---|
   | `archisobasedir=recovery` | The live files are in `/recovery/` on the partition (the archiso hook appends `x86_64/`) |
   | `archisosearchuuid=…` | Which partition to look in (the ESP, found by UUID) |
   | `checksum=y` | Verify `airootfs.sfs` against `airootfs.sha512` before booting (catches corruption) |
9. Clean up:
   ```bash
   cd /
   rm -rf /tmp/recovery
   ```
10. rEFInd scans `EFI/*`, so the entry `archiso-recovery.efi` shows up automatically. Nothing to add to `refind.conf`.
11. **[CUSTOM]** Add a firmware (NVRAM) boot entry, so recovery doesn't depend on rEFInd. A UKI is a standalone EFI program, so the firmware can start it directly:
    ```bash
    sudo efibootmgr --create --disk /dev/sda --part 1 --loader '\EFI\recovery\archiso-recovery.efi' --label 'Arch Recovery'
    ```
    `--create` puts the new entry **first** in the boot order. Put rEFInd back in front:
    ```bash
    efibootmgr
    ```
    Note the numbers of `rEFInd Boot Manager` and `Arch Recovery` (e.g. `Boot0001`, `Boot0003`) and the current `BootOrder`, then set rEFInd first and recovery second, followed by the rest in their old order:
    ```bash
    sudo efibootmgr -o 0001,0003,<the other numbers from BootOrder>
    efibootmgr    # BootOrder should now start with rEFInd
    ```
    Only do this step once: refreshing the recovery (below) rewrites the same file path, so the entry stays valid.

**Keeping it fresh:** a new ISO comes out on the 1st of every month. An old one still works; it just has older tools and keyring. Repeat steps 2–9 every few months, and always before a risky change (e.g. a major system upgrade). Test-boot it once after each refresh, from rEFInd and from the firmware boot menu.

> [NOTE] Firmware updates and "load defaults" can wipe NVRAM boot entries. rEFInd still starts from the removable path (`EFI/BOOT/BOOTX64.EFI`); recreate the entries with the `efibootmgr --create` commands from [6.7](06-boot-chain.md#67-refind) and step 11.
> [NOTE] Both entries live on the same ESP. If the ESP itself is damaged or wiped, a USB stick with the Arch ISO is the last resort; keep one around.

### Using the recovery

1. Reboot into the firmware setup → **disable Secure Boot**. Only toggle it; do **not** reset or clear the keys.
2. Boot. In rEFInd pick **archiso-recovery.efi**, or, if rEFInd doesn't start, open the firmware's one-time boot menu (usually `F8`, `F11` or `F12` at power-on) and pick **Arch Recovery**. You get the familiar live-ISO root shell.
3. Unlock the disk with your password:
   ```bash
   cryptsetup open /dev/sda2 root
   ```
4. Do the repair (e.g. the rollback in [9.2](#92-full-system-rollback), or `arch-chroot`).
   If **rEFInd itself** is broken, mount the system and reinstall it from inside:
   ```bash
   mount -o subvol=@ /dev/mapper/root /mnt
   mount /dev/sda1 /mnt/efi
   arch-chroot /mnt pacman -S refind     # the 99-refind hook runs refind-sync (copies + re-signs)
   arch-chroot /mnt efibootmgr           # "rEFInd Boot Manager" missing? recreate it with the command from 6.7
   umount -R /mnt
   ```
5. Reboot into the firmware → **enable Secure Boot** again. Check with `sbctl status` after booting Arch.

## 9.2 Full system rollback

Restores a snapshot **and** the matching kernel/UKI.

**What's in a snapshot and what isn't:**

| In `@` (so snapshotted) | NOT snapshotted |
|---|---|
| kernel `/boot/vmlinuz-*`, modules `/usr/lib/modules`, pacman DB, `/etc` (incl. `mkinitcpio.conf`, `/etc/kernel/cmdline`, sbctl keys) | the **UKIs on the ESP** (that's where the initramfs lives), plus `@home`, `@log`, `@pkg` (by design) |

**Restoring a snapshot does NOT rebuild the UKI.** mkinitcpio only runs from pacman hooks, and a rollback isn't a pacman transaction. After the swap, the ESP still holds the *newer* kernel's UKI while `@` has the *older* modules, so the system boots half-broken or not at all. The fix is **one `mkinitcpio -P` inside the restored system**. It rebuilds all 4 UKIs from the restored kernel and modules, and sbctl's mkinitcpio hook signs them automatically.

> [NOTE] Swapping `@` gives it a new subvolume ID. This is safe because fstab mounts by name only ([4.3](04-snapper-fstab.md#43-generate-fstab)).
> [NOTE] The optional add-ons in [chapter 10](10-rollback-addons.md) make this faster: no chroot, and a "boot the pre-update state" menu entry.

### Step 1: pick the snapshot

If the system still boots:
```bash
snapper -c root list
```
snap-pac descriptions show the pacman command that ran. You want the **pre** snapshot taken right before the bad update. Note its number `N`.

From recovery, list the snapshots with their descriptions (run this after mounting in Method B, step 2):
```bash
grep -H -e '<date>' -e '<description>' /mnt/@snapshots/*/info.xml
```

### Method A: from the running system

Use this if the system still boots (e.g. via the LTS UKI).

1. Mount the btrfs top level:
   ```bash
   sudo mount -o subvolid=5 /dev/mapper/root /mnt
   ```
2. Swap `@` for a writable copy of snapshot N. Renaming the running root is safe; it takes effect at the next boot:
   ```bash
   sudo mv /mnt/@ /mnt/@.broken
   sudo btrfs subvolume snapshot /mnt/@snapshots/N/snapshot /mnt/@
   ```
3. Rebuild the UKIs from the **restored** system:
   ```bash
   sudo mount --bind /efi /mnt/@/efi
   sudo arch-chroot /mnt/@ mkinitcpio -P
   sudo umount /mnt/@/efi
   sudo umount /mnt
   ```
4. Reboot.

### Method B: from the recovery entry or a USB ISO

Uses the recovery environment from [9.1](#91-on-disk-recovery-environment) (or a USB stick).

1. Disable Secure Boot, boot recovery, then unlock:
   ```bash
   cryptsetup open /dev/sda2 root
   ```
2. Mount the btrfs top level:
   ```bash
   mount -o subvolid=5 /dev/mapper/root /mnt
   ```
3. Swap `@` for a writable copy of snapshot N:
   ```bash
   mv /mnt/@ /mnt/@.broken
   btrfs subvolume snapshot /mnt/@snapshots/N/snapshot /mnt/@
   umount /mnt
   ```
4. Mount the restored system and the ESP, then rebuild the UKIs:
   ```bash
   mount -o subvol=@ /dev/mapper/root /mnt
   mount /dev/sda1 /mnt/efi
   arch-chroot /mnt mkinitcpio -P
   ```
5. Unmount and reboot, then re-enable Secure Boot:
   ```bash
   umount -R /mnt
   reboot
   ```

### After either method

- Check `uname -r` and `snapper -c root list`. The system is on the old state and the snapshot history is intact (it lives in `@snapshots`).
- Once you're happy, delete the broken root:
  ```bash
  sudo mount -o subvolid=5 /dev/mapper/root /mnt
  sudo btrfs subvolume delete /mnt/@.broken
  sudo umount /mnt
  ```
- `@home`, `@log` and the pacman cache were **not** rolled back (by design). Your files and logs stay current.

> **Shortcut:** if the bad update didn't touch `linux-lts`, the **LTS UKI still matches** the restored system, so Method A works even when the main kernel won't boot. Boot `arch-linux-lts.efi` first.
> **Edge case:** if snapshot N is **older than your Secure Boot setup ([8.3](08-post-install.md#83-secure-boot-with-sbctl))**, it has no sbctl keys, so the rebuilt UKIs are unsigned and won't boot with Secure Boot on. Either boot with Secure Boot off once and run `sudo sbctl sign-all`, or copy `/var/lib/sbctl` from `@.broken` into the new `@` before running `mkinitcpio -P`.

---

Next: [10. Faster rollbacks](10-rollback-addons.md) **[OPTIONAL]**
