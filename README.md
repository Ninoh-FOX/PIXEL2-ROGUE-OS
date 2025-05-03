<p align="center"><img class="center" src =https://raw.githubusercontent.com/Ninoh-FOX/PIXEL2_system_mods/refs/heads/main/splash.png></p>

# GKD PIXEL2 ROGUE OS
mods in stock SYSTEM file

These are minor changes made to the original system such as script improvements by unpacking the original SYSTEM file from the boot partition with the following commands:

. sudo unsquashfs SYSTEM

. sudo mksquashfs squashfs-root SYSTEM -noappend -comp gzip -Xcompression-level 9 -b 262144

### SPECIAL FEACTURES:

- Auto poweroff the machine when this is an 1%.
- Vibration warning (vibrate 3 times) when the battery is 10% and 5%.
- Update RETROARCH to version 1.20.0.
- Added Custom Pico8 splore.
- Added FBNEO STANDALONE.
- Custom GMU music player rewrite for the machine with blockkeys fuctions and screenoff.
- Added Drastic mod version by Steward Fu.
- Added mouse virtual emulator.
- Added Portmaster for Pixel 2.

### Installation:

As this repository is structured, the three main folders refer to the three partitions contained on the console's microSD card.

In the releases, you'll find two files: SYSTEM and STORAGE.7z.

### YOU NEED THE TWO FILES!! SYSTEM AND storage.7z.

The SYSTEM file is used to overwrite the existing file on the EMUELEC fat32 partition, which is the OS file system with the corrections.

The STORAGE.7z file contains the files that should be located in the root of the EXT4 STORAGE partition. 
This file must be placed in the /roms/storageupdate directory (you will have to create the folder) to be installed at boot time. This is intended for people who do not have root access to ext4 file systems or user with Windows OS.

All of this works on either a microSD card with the stock OS or with the configured PlumOS OS.

### boot kernel logo:

Put in EMUELEC partition a BMP image with 480*640 size and 24bits color. 

Note: This not is the boot system logo.

### RetroArch ###

controls: 

```
Select + Menu = Open RA Menu.
Select + Start = Close RA.
Select + X = Take screenshot.
Select + Y = Show fps.
Select + B = Set up speed mode.
Select + A = Rewind.
Select + L1 = Load savestate.
Select + L2 = Down savestate slot.
Select + R1 = Save savestate.
Select + R2 = Up savestate slot.

```

### FBNeo standalone ###

controls: 

```
Select + Start close the emulator.
Select + button R2 or L2 open the service menu.
```

### PortMaster ###

Put the file runtimes.7z in the /roms/storageupdate folder (maybe you will have to create the folder). The file will be deleted once it is installed on the system.
~~After installing this update, you will need to launch Portmaster from the "Tools" section before launching any games (as they will not work due to missing files) and reinstall the games for the changes to take effect.~~

### pico8 splore ###

You need download the oficial pico8 files for raspberry pi and put ***PICO_64*** and ***PICO.DAT*** in ***/roms/bios/pico-8/*** folder.

controls: 

```
Menu button: show exit menu from splore
Select button: set mouse mode, L1 is button mouse Right, R1 is button mouser Left
Start + Select: close de emulator.
```

### Drastic ###

Controls:

```
Button L2: set stylus mode, button R1 is touch, dpad move the stylus. (note: in this mode button menu or start+select not works)
Button R2: swap screens.
Button Menu: show drastic menu.
Button Start+Select:  Close de emulator.
```

### usage the module dpad to mouse/touchscreen:

the default setting is (you can changer this in /storage/.config/dpadmouse.cfg)

```
L2 = switch dpad or mouse mode.
R1 = touch
```

You can load the module before the main program by adding the following line before running the emulator:

```
stickmod &
-----
pkill -9 stickmod (in the end of the script)
```

If you have any separate key configurations, it would be:

`stickmod -c /"configpath"/dpadmouse.cfg &`

dpadmouse.cfg has 4 commands:

```
mode_toggle = is the butoon for switch dpad <> mouse (A, B, X, Y, L1, R1, R2, L2, START, SELECT or MENU)
mouse_left = left button mouse to emulate (A, B, X, Y, L1, R1, R2, L2, START, SELECT or MENU, valor -1 disabled this button)
mouse_right = right button mouse to emulate (A, B, X, Y, L1, R1, R2, L2, START, SELECT or MENU)
cursor_speed = cursor speed (in numbre, default is 10, you can up this)
```

### SSH ###

Connect the device to the Internet and on a computer on the same local network, type the following into the terminal:

`ssh root@192.1.1.***`   note: you need the ip of your device

press enter and the password is:

`rogue`

### Features and Fixes:

(in order of incorporation into the system)

- Added full pico8 with mouse support, downloading, and card viewing in ES.
- Added mouse support to scummvm.
- Added the super game boy system and fixed vertical arcade theme.
- Added color correction options in GB/GBC/GBA.
- Added border options in SGB.
- Added support for local game captures in the ES playlist without having to scrape.
- Fixed the menu from opening when capturing a screenshot.
- Added safe system shutdown when the battery reaches 1% to prevent microSD corruption.
- Set new brightness valors.
- Added the storage.7z installer file due to the issue that it must be installed on a Linux system and is not normally accessible from Windows.
- GMU in english.
- Lock key (off screen and block keys) now works in GMU with button Menu.
- Set retroarch joypad driver to sdl2 (better rumble).
- fixed all hotkeys from RetroArch.
- OD-Dinguxcommander (Commander) added to ES tools.
- Fixed PortMaster with RA system configuration games.
- Added fba2012 cores for cps1, cps2, cps3 and neogeo.
- Rebuided mgba/sgb cores.
- Fixed permissions for two system modules.
- Added splash screen.
- fixed splash screen in picoarch, added big font GMU theme.
- Added a binary program to map the Dpad as a mouse or touchstick.
- Fixed the drastic issue with the touchstick.
- reenabled bluetooth services.
- rewrited and upgraded sdl2 for pico8.
- fixed dpad capture in mouse mode, rewrite the code.
- set new mouse mode in pico8.
- set new mouse mode in scummvm.
- set new mouse mode in drastic.
- set ports and pcsx cores to udev joypad.
- fix audio latency in RA (psx).
- added joypad in sdl2 and udev mode.
- added cores setting.
- Added clock time set to tools, a program for set the hour in ES without network.
- Fixed double mouse cursors in mode mouse. (trasparent cursor mouse in wayland/x11)
- rebuild GPSP in 64bits mode to the last version (this fixed the load pkmn roms hacks).
- fixed the system configuration for set cores in 64 or 32 bits.
- fixed the cores/feactures list in ES for 64 or 32 bits.
- fixed the change between IUX and ES.
- build and upgrade pcsx_rearmed core for RA 64 bits.
- build and added beetle_saturn core.
- disabled touch fisical screen services.
- build and upgrade VBAM core for RA 64 bits. (is more slow that GPSP or MGBA, but works with GBA hacks)
- return video gpu driver to LIBMALI for PortMaster problems.
- rewriter and fixed some scripts.
- redef joypad configs.
- rebuild gptokeyb and added gptokeyb2.
- Updated PortMaster.
- Rewrote the GPU drivers script.
- Rewrote the PortMaster script.
- Added GKD Pixel 2 to PortMaster.
- Fixed some ports remapping controls when returning to ES/IUX.
- update and rebuild sdl2 driver for Mesa GL (panfrost) and rockchip GLES (libmali) to 2.32.4.
-  fixed hostkey in portmaster
- added loading splash.
- fixed auto core loader function for arcade games.
- fixed ghost keys in some cores.
- Added kernel boot logo file (place the logo.bmp file in the root of the EMUELEC partition).
- Fixed various base OFW configurations and services.
- Fixed auto core loader not loading custom systems configurations.
- Added Python pip, pygame, and pyxel to the system.
- Fixed random IUX launcher crashes when exiting an application.
- Added support for upgrade portmaster from storage.7z, you not need reinstall the ports now.
- Pico8 splore now reflesh the rom list with the download games without reset ES.
- Fixed sleep mode of factory OS release, this fixed to the random block of the machine.
- Added FBNeo standalone emulator, this run games how GLADMORT!!
- Fixed Fbneo autocore option for RA.
- Rewrote the to option for Pico8 standalone option (fullscreen, perfect pixel) for ES launcher.- fixed some system stock lines.
- Rewritten the base system CPU control program to match the device's CPU data.
- Improved the sleep system by keeping the CPU and GPU as low as possible without affecting the experience.
- Disabled the wake_event services, as they break sleep. I can't remove them from the ES menu, so please don't enable this option.
- Added a warning vibration when shutting down the system at 1% battery (it will vibrate 3 times)
- Added battery warning vibration to 10% and 5% of the battery live.
- FBneo SA, Drastic, and Pico8 SA can now be closed with the Start+Select combination.
- Removed the FBneo SA shutdown feature from the Menu button to avoid closing the emulator at an unwanted time.
- Added configuration options to FBneo SA in the ES menu.
- Fixed mouse cursor synchronization in applications like Drastic.
- Change host name to "rogue_pixel2"
- Change root password to "rogue"
- Fixed minor OFW crashes.
- another fixers.
