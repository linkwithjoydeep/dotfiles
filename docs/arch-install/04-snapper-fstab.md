# 4. Snapper and fstab

Runs on the **live ISO** (snapper commands are run through `arch-chroot`). This is done now because it needs the packages from chapter 3.

Archinstall runs `genfstab` at the very end and sets up snapper with the nested layout. We set up the flat `@snapshots` layout first, then generate fstab.

## Why a flat @snapshots subvolume

Archinstall uses snapper's default nested `.snapshots` (inside `@`). This guide uses a separate top-level `@snapshots` instead:

- The UKIs boot `rootflags=subvol=@`, so a rollback means replacing `@` with a snapshot (`mv @ @.broken` + `btrfs subvolume snapshot @snapshots/N/snapshot @`, see [9.2](09-recovery-rollback.md#92-full-system-rollback)).
- Nested: the snapshot history lives *inside* `@`, so it stays behind in `@.broken`, and deleting `@.broken` deletes it. Flat: `@snapshots` is untouched and the history survives the rollback.
- It works with `snapper-rollback` (AUR, [10.3](10-rollback-addons.md#103-snapper-rollback)), and it's the layout the Arch Wiki suggests. openSUSE-style `snapper rollback` needs GRUB + a default subvolume and doesn't fit rEFInd + UKI.
- It's also a stable path for "boot a snapshot" UKIs (`rootflags=subvol=@snapshots/N/snapshot`, [10.2](10-rollback-addons.md#102-snapshot-boot-entries)).
- Cost: the one-time setup steps below. If `/.snapshots` isn't mounted, snapper silently writes into `@`, so check fstab ([4.3](#43-generate-fstab)).

## 4.1 Create the snapper config on the flat subvolume

`snapper create-config` insists on creating its own `.snapshots` subvolume. We let it, then swap in `@snapshots`:

1. Unmount our `@snapshots` and remove the empty folder:
   ```bash
   umount /mnt/.snapshots
   rmdir /mnt/.snapshots
   ```
2. Create the config **[AI]** (root only; home skipped):
   ```bash
   arch-chroot /mnt snapper --no-dbus -c root create-config /
   ```
3. Delete the nested subvolume snapper just made, then remount `@snapshots` in its place:
   ```bash
   btrfs subvolume delete /mnt/.snapshots
   mkdir /mnt/.snapshots
   mount -o noatime,compress=zstd,subvol=@snapshots /dev/mapper/root /mnt/.snapshots
   ```

## 4.2 Snapshot retention and access for wheel

**[CUSTOM]** Use snapper's own `set-config` command:
```bash
arch-chroot /mnt snapper --no-dbus -c root set-config ALLOW_GROUPS=wheel SYNC_ACL=yes NUMBER_LIMIT=10 NUMBER_LIMIT_IMPORTANT=5 TIMELINE_LIMIT_HOURLY=5 TIMELINE_LIMIT_DAILY=7 TIMELINE_LIMIT_WEEKLY=0 TIMELINE_LIMIT_MONTHLY=0 TIMELINE_LIMIT_YEARLY=0
```

| Setting | Meaning |
|---|---|
| `NUMBER_LIMIT=10` | Keep the last 10 pacman snapshots (default 50). Each pacman run makes a pre + post pair, so this is roughly the last 5 runs. |
| `NUMBER_LIMIT_IMPORTANT=5` | Plus up to 5 "important" ones, counted separately (default 10). snap-pac marks e.g. kernel updates as important. |
| `TIMELINE_LIMIT_HOURLY=5`, `TIMELINE_LIMIT_DAILY=7` | Plus 5 hourly and 7 daily timeline snapshots (the timers are enabled in [7.4](07-desktop-services.md#74-maintenance-timers)). Weekly/monthly/yearly: none. |
| `ALLOW_GROUPS=wheel`, `SYNC_ACL=yes` | Users in `wheel` can list and browse snapshots without sudo. |

Check it with `arch-chroot /mnt snapper --no-dbus -c root get-config`. Then fix permissions:
```bash
chmod 750 /mnt/.snapshots
chown :wheel /mnt/.snapshots
```

Day-to-day snapper commands are in [8.8](08-post-install.md#88-snapper-usage).

## 4.3 Generate fstab

**[AI]** `genfstab`:
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

**[CUSTOM]** Remove the `subvolid=` options genfstab adds, so every subvolume is mounted by name (`subvol=`) only:
```bash
sed -i -E 's/subvolid=[0-9]+,//' /mnt/etc/fstab
cat /mnt/etc/fstab
```
> Why: a rollback ([9.2](09-recovery-rollback.md#92-full-system-rollback)) replaces `@` with a new snapshot, which gets a **new** subvolume ID. If fstab still pinned the old ID, the restored system could fail to mount `/`. Mounting by name (`subvol=/@`) keeps working after any rollback. The Arch Wiki's Btrfs page recommends this.

Check:
- 5 btrfs lines (`/`, `/home`, `/var/log`, `/var/cache/pacman/pkg`, `/.snapshots`) + 1 vfat line for `/efi`.
- Each btrfs line has `subvol=/@…` and **no** `subvolid=`.

---

Next: [5. System basics](05-system-basics.md)
