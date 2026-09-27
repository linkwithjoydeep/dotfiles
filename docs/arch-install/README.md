# Arch Linux manual install

A by-hand Arch Linux install with:

- **LUKS2** full-disk encryption: one password at boot (Plymouth), then automatic login
- **btrfs** subvolumes with **Snapper** snapshots around every pacman run
- **Unified Kernel Images (UKIs)** booted by **rEFInd**, signed for **Secure Boot** with sbctl
- **Hyprland** (via uwsm) with greetd (auto-login) + tuigreet, PipeWire, Bluetooth, printing, firewall
- An on-disk **recovery environment** and documented **rollback** procedures

The steps follow what archinstall's guided installer (`archinstall/scripts/guided.py`) does for this configuration, and say so wherever they deviate from it.

**New here? Start with the [overview](00-overview.md)**: diagrams of the finished system, the disk and EFI partition layout, the boot flow, and what happens on updates and rollbacks.

## How to read this guide

- Follow the chapters **in order**. Each chapter says where its commands run (live ISO, chroot, or the installed system).
- "**Edit**" / "**Create**" means: open the file in your editor of choice and make the change shown.
- Tags:
  - **[AI]**: this is what archinstall does
  - **[CUSTOM]**: deviates from archinstall, with the reason given
  - **[NOTE]**: extra info or a future action
  - **[OPTIONAL]**: can be skipped; nothing later depends on it unless stated
  - **[NVIDIA]**: only for machines with an NVIDIA GPU (see [Different hardware](#different-hardware))

## Values to substitute

The commands use the values below. Replace them wherever they appear if your setup differs.

| What | Value used in this guide | Notes |
|---|---|---|
| Target disk | `/dev/sda` → ESP `/dev/sda1`, LUKS `/dev/sda2` | NVMe partitions are named like `/dev/nvme0n1p1`, `/dev/nvme0n1p2` |
| Windows ESP (dual boot only) | `/dev/nvme0n1p1` | Found in [6.8](06-boot-chain.md#68-windows-boot-entry) |
| Hostname | `joy-arch` | |
| Username | `joy` | |
| Timezone | `Asia/Kolkata` | `ls /usr/share/zoneinfo` |
| Mirror country (fallback) | `India` | `reflector --list-countries` |
| CPU microcode | `amd-ucode` | Intel CPUs: `intel-ucode` |
| GPU driver | NVIDIA open kernel modules (DKMS) | See [Different hardware](#different-hardware) |

## Configuration summary

| Section | Choice |
|---|---|
| Locale | keymap `us`, `en_US.UTF-8`, console font `default8x16` |
| Mirrors | Worldwide first, then reflector-picked fastest local mirrors as fallback |
| Repos | core, extra, **multilib** |
| Disk | Single disk, GPT |
| Partitions | partition 1: 5 GiB FAT32 ESP → `/efi` · partition 2: rest → LUKS2 → btrfs |
| Subvolumes | `@`→`/`, `@home`→`/home`, `@log`→`/var/log`, `@pkg`→`/var/cache/pacman/pkg`, `@snapshots`→`/.snapshots` |
| btrfs options | `compress=zstd`, `noatime`, CoW on |
| Encryption | LUKS2 password typed at the Plymouth prompt on every boot, then greetd auto-login (one password prompt). Secure Boot via sbctl. TPM2 unlock optional, off by default |
| Snapshots | Snapper, root config only, + snap-pac |
| Swap | zram, zstd |
| Bootloader | rEFInd + UKI, NVRAM entry **and** removable `/EFI/BOOT/BOOTX64.EFI`, optional Windows chainload entry |
| Plymouth | theme `spinner` |
| Kernels | `linux`, `linux-lts` |
| Users | root password set; one user in `wheel` (sudo), shell zsh |
| Profile | Desktop → Hyprland (polkit seat access), NVIDIA open DKMS |
| Greeter | greetd: auto-login after disk unlock, tuigreet after logout (to be replaced by a Quickshell greeter later) |
| Apps | bluetooth, pipewire, cups (+avahi), power-profiles-daemon, ufw, fonts |
| Network | NetworkManager (wpa_supplicant backend) + applet |
| Timezone / NTP | your timezone, systemd-timesyncd |
| Recovery | On-disk archiso UKI in rEFInd (unsigned; boot it with Secure Boot off) |

> ⚠️ **This guide wipes the target disk.** Other disks (e.g. one holding Windows) are not touched, but device names can change between boots of the live ISO. Always confirm the target with `lsblk -o NAME,SIZE,MODEL` before wiping ([2.1](02-disk-setup.md#21-partition)).

## Chapters

| # | Chapter | Runs in |
|---|---|---|
| 0 | [Overview: what you're building](00-overview.md) | read first |
| 1 | [Prepare the live environment](01-live-environment.md) | live ISO |
| 2 | [Partition, encrypt and format the disk](02-disk-setup.md) | live ISO |
| 3 | [Install the base system](03-base-install.md) | live ISO |
| 4 | [Snapper and fstab](04-snapper-fstab.md) | live ISO |
| 5 | [System basics](05-system-basics.md) | chroot |
| 6 | [Initramfs, UKIs and bootloader](06-boot-chain.md) (Windows entry **[OPTIONAL]**) | chroot |
| 7 | [Desktop, services and first boot](07-desktop-services.md) | chroot |
| 8 | [Post-install](08-post-install.md) (TPM unlock and printer **[OPTIONAL]**) | installed system |
| 9 | [Recovery and rollback](09-recovery-rollback.md) (recovery environment **[OPTIONAL]**) | installed system / recovery |
| 10 | [Faster rollbacks](10-rollback-addons.md) **[OPTIONAL]** | installed system |
| A | [Replacing desktop components later](appendix-replacing-components.md) | installed system |

## Different hardware

The commands target an AMD CPU + NVIDIA GPU desktop that dual-boots Windows from a second disk. For other machines:

| If you have… | Change |
|---|---|
| An Intel CPU | Install `intel-ucode` instead of `amd-ucode` ([3.2](03-base-install.md#32-install-packages)). The `microcode` hook picks up whichever is installed. |
| No NVIDIA GPU (AMD or Intel graphics only) | Skip the NVIDIA package group ([3.2](03-base-install.md#32-install-packages)) and install the Mesa/Vulkan drivers for your GPU instead (see the Arch Wiki pages *AMDGPU* / *Intel graphics*). Leave `MODULES=()` empty ([6.1](06-boot-chain.md#61-mkinitcpio-systemd-initramfs-and-early-kms)), skip the NVIDIA pacman hook ([6.2](06-boot-chain.md#62-nvidia-pacman-hook)) and the NVIDIA env vars ([8.6](08-post-install.md#86-hyprland-on-nvidia-and-multi-gpu)). multilib is still useful for Steam/Wine. |
| Only one GPU | Skip the `AQ_DRM_DEVICES` part of [8.6](08-post-install.md#86-hyprland-on-nvidia-and-multi-gpu). |
| A laptop with two GPUs | Read the laptop note in [8.6](08-post-install.md#86-hyprland-on-nvidia-and-multi-gpu). Intel laptops may also need `sof-firmware` ([3.2](03-base-install.md#32-install-packages)). |
| No Windows install | Skip [6.8](06-boot-chain.md#68-windows-boot-entry) and the Windows notes in [5.2](05-system-basics.md#52-timezone-and-ntp) and [8.3](08-post-install.md#83-secure-boot-with-sbctl). Still enroll Microsoft's keys (`-m`) in 8.3 if you have a dedicated GPU. |
| An NVMe target disk | Replace `/dev/sda1` / `/dev/sda2` with `/dev/nvme0n1p1` / `/dev/nvme0n1p2` (or whatever `lsblk` shows) everywhere. |
