# 2. Partition, encrypt and format the disk

Runs on the **live ISO**. archinstall equivalent: `FilesystemHandler.perform_filesystem_operations()`.

> ⚠️ **This chapter wipes the target disk** (`/dev/sda` in the commands; see [Values to substitute](README.md#values-to-substitute)). Device names can change between boots of the live ISO, so always confirm the disk by its model and size first.

## 2.1 Partition

**[AI]** best-effort layout. **[CUSTOM]** 5 GiB ESP mounted at `/efi`.

Archinstall creates a 1 GiB FAT32 ESP at `/boot`. We use 5 GiB at `/efi` so that `/boot` (kernels) stays inside the encrypted `@` subvolume, which means it gets snapshotted. The ESP only holds rEFInd, the UKIs, themes, the optional recovery environment ([9.1](09-recovery-rollback.md#91-on-disk-recovery-environment)) and optional snapshot UKIs ([10.2](10-rollback-addons.md#102-snapshot-boot-entries)).

1. Confirm the disk. Check that the MODEL and SIZE columns match the disk you intend to wipe:
   ```bash
   lsblk -o NAME,SIZE,MODEL
   ```
2. Erase old partition-table signatures:
   ```bash
   wipefs -a /dev/sda
   ```
3. Partition with `cfdisk`:
   ```bash
   cfdisk /dev/sda
   ```
   - "Select label type" → **gpt**
   - **[ New ]** → size `5G` → **[ Type ]** → `EFI System`
   - Arrow down to the remaining free space → **[ New ]** → accept the full size → **[ Type ]** → `Linux LUKS` (if that isn't listed, `Linux filesystem` works too)
   - **[ Write ]** → type `yes` → **[ Quit ]**
4. Check the result. You should see `sda1` at 5G and `sda2` taking the rest:
   ```bash
   lsblk /dev/sda
   ```

## 2.2 Format the ESP

```bash
mkfs.fat -F 32 -n EFI /dev/sda1
```

## 2.3 Create the LUKS2 container

**[AI]** exact archinstall parameters (`lib/disk/luks.py`):
```bash
cryptsetup --type luks2 --pbkdf argon2id --hash sha512 --key-size 512 --iter-time 2000 --use-urandom --verify-passphrase luksFormat /dev/sda2
```
Type `YES` (uppercase), then your disk password twice.

> [CUSTOM] `--iter-time 2000`: argon2 runs for ~2 s each time you type the password. archinstall's default is `10000` (~10 s); Omarchy's installer also uses `2000`.
> You type this password on **every boot** (it's the only password prompt, see [7.3](07-desktop-services.md#73-greeter-greetd-and-tuigreet)), so 2 s is a good balance. With a strong passphrase, the passphrase length matters far more than the iteration time.
> To change it later without reformatting: add a new keyslot with `sudo cryptsetup luksAddKey --iter-time <ms> /dev/sda2`, then remove the old one with `sudo cryptsetup luksRemoveKey /dev/sda2` (enter the old passphrase).

Open it:
```bash
cryptsetup --allow-discards --persistent open /dev/sda2 root
```
> [CUSTOM] `--allow-discards --persistent` stores "allow TRIM" in the LUKS2 header, so btrfs TRIM actually reaches the SSD (archinstall doesn't pass it through). Because it's stored in the header, no kernel parameter is needed for it later.
> Trade-off: an attacker could see which blocks are unused (not their contents). This is the standard choice for SSDs.

## 2.4 Create btrfs and subvolumes

**[AI]** archinstall's default 4 subvolumes. **[CUSTOM]** plus `@snapshots`.
```bash
mkfs.btrfs -L arch /dev/mapper/root
mount /dev/mapper/root /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@pkg
btrfs subvolume create /mnt/@snapshots
umount /mnt
```
`@snapshots` is a **flat, top-level** subvolume instead of archinstall's nested `.snapshots`. See [Why a flat @snapshots](04-snapper-fstab.md#why-a-flat-snapshots-subvolume) for the reasoning.

## 2.5 Mount everything

**[AI]** `compress=zstd` comes from archinstall's "Use compression" option.
**[CUSTOM]** `noatime` stops btrfs writing metadata on every file read, which would otherwise bloat snapshots.

```bash
mount -o noatime,compress=zstd,subvol=@ /dev/mapper/root /mnt
mount --mkdir -o noatime,compress=zstd,subvol=@home /dev/mapper/root /mnt/home
mount --mkdir -o noatime,compress=zstd,subvol=@log /dev/mapper/root /mnt/var/log
mount --mkdir -o noatime,compress=zstd,subvol=@pkg /dev/mapper/root /mnt/var/cache/pacman/pkg
mount --mkdir -o noatime,compress=zstd,subvol=@snapshots /dev/mapper/root /mnt/.snapshots
mount --mkdir -o fmask=0077,dmask=0077 /dev/sda1 /mnt/efi
```
Check: `lsblk /dev/sda` should show all six mountpoints.

`ssd`, `space_cache=v2` and `discard=async` are btrfs defaults on SSDs and appear in fstab automatically. Because btrfs already trims continuously with `discard=async`, `fstrim.timer` is not needed (archinstall doesn't enable it on btrfs either).

---

Next: [3. Install the base system](03-base-install.md)
