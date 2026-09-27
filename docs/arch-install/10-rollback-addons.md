# 10. Faster rollbacks

**[OPTIONAL]** Post-install add-ons that make the rollback in [9.2](09-recovery-rollback.md#92-full-system-rollback) faster. Set them up any time after the system is running, in this order (each builds on the previous one):

| Add-on | What you get | Needs |
|---|---|---|
| [10.1 UKI backup](#101-uki-backup-inside-every-snapshot) | Every snapshot carries its own matching, already-signed UKIs, so a rollback needs no chroot or `mkinitcpio` | — |
| [10.2 Snapshot boot entries](#102-snapshot-boot-entries) | The states from before your last 3 pacman runs, bootable read-only from a rEFInd **submenu** (the main boot screen stays clean). Try them, and roll back from there, without the recovery ISO or turning Secure Boot off | 10.1 |
| [10.3 snapper-rollback](#103-snapper-rollback) (AUR, CLI) | One command for the "swap `@`" step | 10.1 recommended, [paru](08-post-install.md#85-aur-helper-paru) |

## 10.1 UKI backup inside every snapshot

**Idea:** the UKIs live on the ESP, which is never snapshotted. So right before snap-pac takes its **pre** snapshot, we copy the current UKIs into `/boot/uki-backup/`, which is inside `@`. We copy again after the transaction, so the **post** snapshot matches too.

1. **Create** `/usr/local/bin/uki-backup` with:
   ```sh
   #!/bin/sh
   # Copy the current (signed) UKIs into /boot, which is inside @,
   # so every snapper snapshot contains the UKIs that match its kernel.
   # --update: only copy if the UKI changed. Unchanged copies keep sharing
   # disk space between snapshots.
   mkdir -p /boot/uki-backup
   cp --update --preserve=timestamps \
       /efi/EFI/Linux/arch-linux.efi \
       /efi/EFI/Linux/arch-linux-lts.efi \
       /boot/uki-backup/
   ```
   Make it executable and run it once:
   ```bash
   sudo chmod +x /usr/local/bin/uki-backup
   sudo uki-backup
   ls -lh /boot/uki-backup
   ```
   (Fallback UKIs are skipped to save space; they can always be rebuilt with `mkinitcpio -P`.)

2. **Create** `/etc/pacman.d/hooks/00-uki-backup-pre.hook` with:
   ```ini
   [Trigger]
   Operation = Install
   Operation = Upgrade
   Operation = Remove
   Type = Package
   Target = *

   [Action]
   Description = Backing up UKIs into /boot (before snapshot)...
   When = PreTransaction
   Exec = /usr/local/bin/uki-backup
   ```

3. **Create** `/etc/pacman.d/hooks/zy-uki-backup-post.hook` with:
   ```ini
   [Trigger]
   Operation = Install
   Operation = Upgrade
   Operation = Remove
   Type = Package
   Target = *

   [Action]
   Description = Backing up UKIs into /boot (after rebuild)...
   When = PostTransaction
   Exec = /usr/local/bin/uki-backup
   ```

**Why these names:** pacman runs hooks in alphabetical order of their file names (across `/etc/pacman.d/hooks` and `/usr/share/libalpm/hooks`):

| Order | Hook | Does |
|---|---|---|
| Pre 1 | `00-uki-backup-pre` (ours) | copies the current UKIs into `/boot/uki-backup` |
| Pre 2 | `05-snap-pac-pre` | **pre** snapshot, which now contains the matching UKIs |
| Post | `90-mkinitcpio-install`, `nvidia.hook` | rebuild + sign UKIs (if the kernel/driver changed) |
| Post | `zy-uki-backup-post` (ours) | copies the new UKIs |
| Post | `zz-sbctl`, then `zz-snap-pac-post` | signing, then the **post** snapshot with the new UKIs |

**Space:** ~250 MB in `@`. Unchanged UKIs are shared between snapshots, so each **kernel update** adds ~250 MB until snapper's cleanup removes the old snapshots.

**Rolling back with the backup** (replaces the `mkinitcpio -P` step in [9.2](09-recovery-rollback.md#92-full-system-rollback)):
- **Method A** (running system): after the swap (step 2), instead of step 3 run:
  ```bash
  sudo cp /mnt/@/boot/uki-backup/*.efi /efi/EFI/Linux/
  sudo umount /mnt
  ```
- **Method B** (recovery): after mounting in step 4, instead of `arch-chroot … mkinitcpio -P` run:
  ```bash
  cp /mnt/boot/uki-backup/*.efi /mnt/efi/EFI/Linux/
  ```
- The copies are already signed, so they boot with Secure Boot on. After booting the restored system, run `sudo mkinitcpio -P` once to bring the fallback UKIs back in line.
- Snapshots taken **before** you set this up have no `/boot/uki-backup`. Use the normal 9.2 steps for those.

## 10.2 Snapshot boot entries

**Idea:** keep bootable UKIs for the **last 3 pre snapshots**, i.e. the states right before your last 3 pacman runs, in a rEFInd submenu. Each one uses the kernel and initramfs saved inside that snapshot ([10.1](#101-uki-backup-inside-every-snapshot)), with two cmdline changes:
- `rootflags=subvol=@snapshots/N/snapshot`: use the snapshot as `/`.
- `systemd.volatile=overlay`: snapshots are read-only, so systemd puts a RAM layer on top. You can use the system normally, and every change to `/` is thrown away at reboot.

They're signed with your keys, so they boot with Secure Boot on. You unlock the disk with your password at the Plymouth prompt and auto-login applies, like the normal system.

**Keeping the boot screen clean:** rEFInd stops auto-listing `EFI/Linux`. Instead there's one manual **"Arch Linux"** entry, and everything else lives in its submenu (select it and press `F2`, `Insert` or `Tab`):
```
Arch Linux                                  ← Enter boots arch-linux.efi (default)
 ├─ Linux LTS
 ├─ Fallback (linux)
 ├─ Fallback (linux-lts)
 ├─ Snapshot 212 - 2026-10-03 - pacman -Syu     ← newest
 ├─ Snapshot 205 - 2026-09-30 - pacman -S foo
 └─ Snapshot 198 - 2026-09-28 - pacman -Syu
Windows 11
archiso-recovery.efi
```
The `snapshot-uki` script writes this menu to `/efi/EFI/refind/arch-entries.conf`, and `refind.conf` includes it.

> ⚠️ This is the most advanced part of the guide. Test it once right after setting it up (step 7), before you need it.

1. Prerequisite: 10.1 is set up. (`ukify` is already installed from [3.2](03-base-install.md#swap-bootloader-and-splash).)

2. **Edit** `/etc/mkinitcpio.conf`: add `sd-volatile` to `HOOKS`, right after `sd-encrypt`:
   ```ini
   HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block plymouth sd-encrypt sd-volatile filesystems fsck)
   ```
   `sd-volatile` adds systemd's volatile-root support to the initramfs. It does **nothing** unless `systemd.volatile=` is on the kernel cmdline, so normal boots are unaffected. Rebuild and refresh the backup:
   ```bash
   sudo mkinitcpio -P
   sudo uki-backup
   ```
   Only snapshots taken **after** this step contain an initramfs that can boot read-only.

3. **Create** `/usr/local/bin/snapshot-uki` with:
   ```sh
   #!/bin/sh
   # Keep bootable UKIs for the newest snapper "pre" snapshots and list them
   # in a rEFInd submenu under "Arch Linux".
   #
   # Each snapshot UKI boots that snapshot read-only (changes go to RAM), using
   # the kernel + initramfs that uki-backup saved inside the snapshot.
   #
   # Usage: snapshot-uki        -> add the newest "pre" snapshot (state before last pacman run)
   #        snapshot-uki <N>    -> add snapshot number N
   set -e

   KEEP=3                                   # how many snapshot entries to keep
   LINUX=/efi/EFI/Linux
   MENU=/efi/EFI/refind/arch-entries.conf

   # 1. Which snapshot to add
   if [ -n "$1" ]; then
       N="$1"
   else
       N="$(snapper --csvout -c root list --columns number,type | awk -F, '$2 == "pre" { n = $1 } END { print n }')"
   fi
   SRC="/.snapshots/$N/snapshot/boot/uki-backup/arch-linux.efi"
   OUT="$LINUX/arch-snapshot-$N.efi"

   # 2. Build its UKI (only if the snapshot has a UKI backup and we haven't built it yet)
   if [ -f "$SRC" ] && [ ! -f "$OUT" ]; then
       TMP="$(mktemp -d)"
       trap 'rm -rf "$TMP"' EXIT

       # take kernel, initramfs and cmdline out of the snapshot's UKI
       objcopy --dump-section .linux="$TMP/vmlinuz" \
               --dump-section .initrd="$TMP/initrd" \
               --dump-section .cmdline="$TMP/cmdline" \
               "$SRC" "$TMP/discard.efi"

       # point root at the snapshot and add the RAM overlay
       CMDLINE="$(tr -d '\0\n' < "$TMP/cmdline" | sed "s|rootflags=subvol=@ |rootflags=subvol=@snapshots/$N/snapshot |") systemd.volatile=overlay"

       ukify build --linux "$TMP/vmlinuz" --initrd "$TMP/initrd" --cmdline "$CMDLINE" --output "$OUT"

       # sign it (only once Secure Boot keys are enrolled)
       if sbctl status 2>/dev/null | grep -q 'Setup Mode:.*Disabled'; then
           sbctl sign "$OUT"
       fi
   fi

   # 3. Remove UKIs whose snapshot was deleted, then keep only the newest $KEEP
   for f in "$LINUX"/arch-snapshot-*.efi; do
       [ -e "$f" ] || continue
       n="${f##*arch-snapshot-}"; n="${n%.efi}"
       [ -d "/.snapshots/$n/snapshot" ] || rm -f "$f"
   done
   ls -1v "$LINUX"/arch-snapshot-*.efi 2>/dev/null | head -n -"$KEEP" | xargs -r rm -f

   # 4. Write the rEFInd menu: main entry + submenu (newest snapshot first)
   {
       echo 'menuentry "Arch Linux" {'
       echo '    icon   /EFI/refind/icons/os_arch.png'
       echo '    loader /EFI/Linux/arch-linux.efi'
       echo '    submenuentry "Linux LTS" {'
       echo '        loader /EFI/Linux/arch-linux-lts.efi'
       echo '    }'
       echo '    submenuentry "Fallback (linux)" {'
       echo '        loader /EFI/Linux/arch-linux-fallback.efi'
       echo '    }'
       echo '    submenuentry "Fallback (linux-lts)" {'
       echo '        loader /EFI/Linux/arch-linux-lts-fallback.efi'
       echo '    }'
       for f in $(ls -1vr "$LINUX"/arch-snapshot-*.efi 2>/dev/null); do
           n="${f##*arch-snapshot-}"; n="${n%.efi}"
           info="/.snapshots/$n/info.xml"
           date="$(sed -n 's:.*<date>\(.*\) .*</date>.*:\1:p' "$info")"
           desc="$(sed -n 's:.*<description>\(.*\)</description>.*:\1:p' "$info" | tr -d '"' | cut -c1-40)"
           echo "    submenuentry \"Snapshot $n - $date - $desc\" {"
           echo "        loader /EFI/Linux/${f##*/}"
           echo '    }'
       done
       echo '}'
   } > "$MENU"

   # 5. Copy the updated menu to the removable path too (EFI/BOOT)
   /usr/local/bin/refind-sync
   ```
   Make it executable:
   ```bash
   sudo chmod +x /usr/local/bin/snapshot-uki
   ```
   Change how many snapshot entries are kept with `KEEP=` at the top. Each one is ~100–150 MB on the ESP.

   The `sed` in step 2 of the script relies on the cmdline containing `rootflags=subvol=@ ` followed by a space ([6.3](06-boot-chain.md#63-kernel-command-line)).

4. **Edit** `/efi/EFI/refind/refind.conf` and add at the end:
   ```
   # Arch entries are defined manually (with submenus) in arch-entries.conf,
   # so don't also auto-list the UKIs in EFI/Linux.
   dont_scan_dirs EFI/Linux
   include arch-entries.conf
   default_selection "Arch Linux"
   ```
   - If `refind.conf` has an uncommented `scanfor` line, make sure it includes `manual`.
   - If you set another `default_selection` earlier (e.g. `"arch-linux.efi"` from the [6.7](06-boot-chain.md#67-refind) note), remove that line so only this one is left.
   - `dont_scan_dirs EFI/Linux` replaces rEFInd's built-in skip list. That list only covers tool folders you don't have, so nothing else changes.
   - The Windows entry ([6.8](06-boot-chain.md#68-windows-boot-entry)) and `archiso-recovery.efi` ([9.1](09-recovery-rollback.md#91-on-disk-recovery-environment)) stay as top-level entries.

5. Generate the menu for the first time:
   ```bash
   sudo snapshot-uki
   cat /efi/EFI/refind/arch-entries.conf
   ```
   The first time there may be no snapshot entries yet (no pre snapshot with a UKI backup). The main entry and the LTS/fallback submenu entries are there regardless.

6. Refresh automatically after every pacman run. **Edit** `/etc/pacman.d/hooks/zy-uki-backup-post.hook` (from 10.1) and change its `Exec` line to:
   ```ini
   Exec = /bin/sh -c '/usr/local/bin/uki-backup && /usr/local/bin/snapshot-uki'
   ```
   The UKI is only built once per new snapshot, so this adds a few seconds to a pacman run. Also run `sudo snapshot-uki` after deleting snapshots by hand, to tidy the menu.

7. **Test it once:**
   ```bash
   sudo pacman -S --noconfirm fastfetch    # any reinstall creates a snap-pac pre/post pair
   cat /efi/EFI/refind/arch-entries.conf   # a "Snapshot N" submenu entry should be listed
   ```
   Reboot. In rEFInd select **Arch Linux**, press `F2`, pick the snapshot entry, and unlock the disk. Then check:
   ```bash
   cat /proc/cmdline    # rootflags=subvol=@snapshots/N/snapshot … systemd.volatile=overlay
   findmnt /            # FSTYPE "overlay"
   ```
   If `systemd-remount-fs.service` shows as failed in this mode, that's harmless: `/` is intentionally read-only underneath.

**Using it after a bad update:**
1. Reboot → rEFInd → **Arch Linux** → `F2` → the newest **Snapshot** entry. This is the pre-update system. Unlock the disk as usual.
2. If everything works here, make it permanent with [9.2 Method A](09-recovery-rollback.md#method-a-from-the-running-system) plus the UKI-backup copy from [10.1](#101-uki-backup-inside-every-snapshot). N is in the entry name, and in `cat /proc/cmdline`.
3. Don't install packages or change system settings in this mode: changes to `/` are lost at reboot. But `/home`, `/var/log` and the pacman cache are the **real** subvolumes, so changes there *are* kept.

> [NOTE] If a snapshot entry ever points at a deleted snapshot, it just fails to boot. Run `sudo snapshot-uki` to rebuild the list.

## 10.3 snapper-rollback

**[OPTIONAL]** AUR, CLI. Automates the "mount top level → move `@` aside → snapshot N to `@`" part of [9.2 Method A](09-recovery-rollback.md#method-a-from-the-running-system). It does **not** handle UKIs, so you still copy the UKI backup (10.1) or run `mkinitcpio -P` afterwards.

1. Install:
   ```bash
   paru -S snapper-rollback
   ```
2. **Edit** `/etc/snapper-rollback.conf` to match this layout:
   ```ini
   [root]
   subvol_main = @
   subvol_snapshots = @snapshots
   mountpoint = /btrfsroot
   dev = /dev/mapper/root
   ```
   (Check the package's README/`--help` after installing: option names can change between versions.)
3. Roll back to snapshot N, restore the matching UKIs, then reboot:
   ```bash
   sudo snapper-rollback N
   sudo mount -o subvolid=5 /dev/mapper/root /mnt
   sudo cp /mnt/@/boot/uki-backup/*.efi /efi/EFI/Linux/
   sudo umount /mnt
   reboot
   ```

---

Next: [Appendix A: Replacing desktop components later](appendix-replacing-components.md)
