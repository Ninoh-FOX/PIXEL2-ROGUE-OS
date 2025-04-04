<p align="center"><img class="center" src =https://raw.githubusercontent.com/Ninoh-FOX/PIXEL2_system_mods/refs/heads/main/splash.png></p>

# GKD PIXEL2 system mods
mods in stock SYSTEM file

These are minor changes made to the original system such as script improvements by unpacking the original SYSTEM file from the boot partition with the following commands:

. sudo unsquashfs SYSTEM

. sudo mksquashfs squashfs-root SYSTEM -noappend -comp gzip -Xcompression-level 9 -b 262144

### Installation:

As this repository is structured, the three main folders refer to the three partitions contained on the console's microSD card.

In the releases, you'll find two files: SYSTEM and STORAGE.7z.

The SYSTEM file is used to overwrite the existing file on the EMUELEC fat32 partition, which is the OS file system with the corrections.

The STORAGE.7z file contains the files that should be located in the root of the EXT4 STORAGE partition. 
This file must be placed in the /roms/storageupdate directory (you will have to create the folder) to be installed at boot time. This is intended for people who do not have root access to ext4 file systems or user with Windows OS.

All of this works on either a microSD card with the stock OS or with the configured PlumOS OS.

### Install native pico8:

You need the oficial pico8 files for Raspberry Pi

Put pico8_64 and pico8.dat files in /roms/bios/pico-8 folder.

### Features and Fixes:

Added full pico8 with mouse support, downloading, and card viewing in ES.

Added mouse support to scummvm.

Added the super game boy system and fixed vertical arcade theme.

Added color correction options in GB/GBC/GBA.

Added border options in SGB.

Added support for local game captures in the ES playlist without having to scrape.

Fixed the menu from opening when capturing a screenshot.

Added safe system shutdown when the battery reaches 1% to prevent microSD corruption.

Set new brightness valors.

Added the storage.7z installer file due to the issue that it must be installed on a Linux system and is not normally accessible from Windows.

GMU in english.

Lock key (off screen and block keys) now works in GMU with button Menu.

Set retroarch joypad driver to sdl2 (better rumble).

fixed all hotkeys from RetroArch.

OD-Dinguxcommander (Commander) added to ES tools.

Fixed PortMaster with RA system configuration games.

Added fba2012 cores for cps1, cps2, cps3 and neogeo.

Rebuided mgba/sgb cores.

Fixed permissions for two system modules.

Added splash screen.

fixed splash screen in picoarch, added big font GMU theme.

Added a binary program to map the Dpad as a mouse or touchstick.

Fixed the drastic issue with the touchstick.

another fixers.
