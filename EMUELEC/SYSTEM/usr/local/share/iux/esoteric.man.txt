# Esoteric

[Esoteric](https://github.com/podulator/esoteric/) is a fork of [GMenu2X](http://mtorromeo.github.com/gmenu2x) developed for the ANBERNIC RG-350 - (hence 350teric), released under the GNU GPL license v2.
It also supports the GKD350H and the PocketGo 2.

View releases [changelog](ChangeLog.md).

## Installation

Copy the latest [Release](https://github.com/podulator/esoteric/releases/) opk to your RG-350, and launch it.

If you decide you want to install it, there is an option to do that in the Settings menu.
You can uninstall it as the default launcher the same way.

The 'update' option shows if you have installed 350teric but are running from a new opk. 
It overwrites the binary, the manual, and the settings file, and replaces any missing files in subfolders.

## Controls

- D-Pad L, R: PageUp/PageDown on lists;
- D-Pad U, D: Up, Down and wrap on lists
- A: Accept / Launch selected link / Confirm action;
- B: Back / Cancel action / Goes up one directory in file browser;
- Y: Bring up the manual/readme;
- L1, R1: Switch between sections / PageUp/PageDown on lists;
- L2, R2: Jump to next letter in a list
- START: System settings;
- SELECT: Bring up the contextual menu;

In settings:

- A, LEFT, RIGHT: Accept, select or toggle setting;
- B: Back or cancel edits and return;
- START: Save edits and return;
- SELECT: Clear or set default value.

## New Features (and how to use them)

### Sections

- Section hiding (hit sleect -> hide section)
  - Unhide in Settings menu -> unhide all sections

### Apps

- Fully Editable Apps, even OPK's (press select on an App, choose edit)
  - Set rom directory for an app with 'Selector Path'
  - Set file extension filters with 'File Filter', eg. '.snes,.sfc'
  - Set specific CPU frequency
  - Set aliases file for friendly names in rom browser
- Manuals are shown if present by hitting Y. There is an icon in the tray to tell you if there is a manual.
- Favourites
  - Apps can be favourited (select an app, hit x)
  - Roms and a specific emulagtor can be favourited (select a rom in the rom launcher, hit x)
    - These are all editable also, so you can set a cpu speed for a rom / emulator combo
- App hiding (select an app, hit select -> hide)
  - Unhide temporarily via the Settings menu -> show hidden links
- Choose your install path (Settings -> External apps path)

### Device

- This depends on your hardware, but includes
  - Backlight level
  - Screen timeout in seconds
  - Sleep (or power off) toggle and timeout in minutes
  - Launcher clock speed
  - Button repeat toggle and speed
  - Volume level
  - Aspect ratio control
  - Option to apply volume and brightness settings on first boot

Access these options in the Device menu

## How to have previews in Selector Browser

- Create a folder called `.previews` in a rom folder
- Fill it full of shiny
- The name of the file (without filetype suffix) of rom and preview have to be exactly the same.
- Suported image types are .png or .jpg;
- To change how the previews are shown, see the [Skinning]("#Skinning) section

## Skinning

Start by looking at an existing skin file, as they are fully commented.
These can be found under `~/.esoteric/skins`.

If you don't supply an asset, like an icon for battery level etc, then esoteric will look for it in the Default skin next, and then in the root of the skin folder, so re-use existing assets when it suits.

Helper icons (battery level, brightness, volume etc) have an auto fluid layout to best use the space.

In single row mode the scroll bar is force hidden.

In single column mode, with no cions, the text aligns centre.

You can have a 1st run animation and sound splash screen by using the skins/loader folder. See the minimal skin for an example. 

- The rest is WIP

## Thanks 

All at [Retro Game Handhelds](https://discord.gg/29DrhQf)

## Contacts

GMenu2X Copyright (c) 2006-2010 [Massimiliano Torromeo](mailto:massimiliano.torromeo@gmail.com); 
GMenuNX 2018 by [@pingflood](https://boards.dingoonity.org/profile/pingflood/);
Esoteric 2019 and beyond by [@podulator](podulator#5243);

Visit the [Discord channel](https://discord.gg/29DrhQf)!

[Esoteric](http://podulator.github.com/esoteric) homepage for more info.
