#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

# Source predefined functions and variables
. /etc/profile

set_kill set "-9 pico8_64"

GAME_DIR="/storage/roms/pico-8/"
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
EMULATOR=$(echo "${3}"| sed "s#^/.*/##")
PIXEL=$(get_setting Perfect_Pixel pico-8 pico-8)
FULLSCREEN=$(get_setting Set_fullscreen pico-8 pico-8)

if [ ! -d "/storage/pico" ]; then
  mkdir /storage/pico

  cp -R /usr/share/pico-8/* /storage/pico/

  # Create the content for pico.sh
  PICO_SH_CONTENT='#!/bin/bash
. /etc/profile

cd $(dirname "$0")
export HOME=/storage/pico
set_kill set "-9 pico8_64"
  
if [ "$1" == "/storage/roms/pico-8/Splore.png" ]; then

    export LD_LIBRARY_PATH="$HOME/lib1:${LD_LIBRARY_PATH}"
	kill_sense &
    stickmod -c /storage/pico/dpadmouse.cfg &
    sleep 1

    /storage/roms/bios/pico-8/pico8_64 -draw_rect 0,0,640,480 -splore -root_path /storage/roms/pico-8 -joystick 0

    pkill -9 stickmod
	pkill -9 kill_sense

else

    export LD_LIBRARY_PATH="$HOME/lib2:${LD_LIBRARY_PATH}"
	kill_sense &
    stickmod -c /storage/pico/dpadmouse.cfg &
    sleep 1

    /storage/roms/bios/pico-8/pico8_64 -draw_rect 0,0,640,480 -run "$1" -root_path /storage/roms/pico-8 -joystick 0

    pkill -9 stickmod
	pkill -9 kill_sense
fi

for file in /storage/pico/.lexaloffle/pico-8/bbs/carts/*.p8.png; do
    base_name="$(basename "$file" .p8.png)"
    roms="/storage/roms/pico-8/$base_name"
    images="/storage/roms/pico-8/images/$base_name"

    if [ ! -e "$roms.p8" ]; then
       cp "$file" "$roms.p8"
       cp "$file" "$images.png"
    fi
done

sync
'

  PICO_IUX='title=Pico8 splore
description=pico-8 splore
icon=icons/pico_f.png
exec=/storage/pico/pico.sh
workdir=/storage/pico/
selectorbrowser=false
selectorFilter=.p8,.png,.P8,.PNG
selectorscreens=images
selectordir=/storage/roms/pico-8
selectorbrowser=false
perfMode=true
thiscore=no
strcore=no
'

  # Create the pico.sh file and make it executable
  echo "$PICO_SH_CONTENT" > /storage/pico/pico.sh
  chmod +x /storage/pico/pico.sh
  
  echo "$PICO_IUX" > /storage/iux/sections/emulators/09pico8
  chmod +x /storage/iux/sections/emulators/09pico8
fi

export HOME="/storage/pico"

# check if the file being launched contains "Splore" and if so launch Pico-8 Splore otherwise run the game directly
shopt -s nocasematch
if [[ "${1}" == *splore* ]]; then
  OPTIONS="-splore"
  LIBRARY="/usr/share/pico-8/lib1"
else
  OPTIONS="-run"
  CART="${1}"
  LIBRARY="/usr/share/pico-8/lib2"
fi
shopt -u nocasematch

if [ "${PIXEL}" = "ON" ]
then
  OPTIONS="${OPTIONS} -pixel_perfect 1"
fi

if [ "${FULLSCREEN}" = "ON" ]
then
  OPTIONS="${OPTIONS} -draw_rect 0,0,640,480"
fi

LAUNCH="/storage/roms/bios/pico-8/pico8_64"

# mark the binary executable to cover cases where the user adding the binaries doesn't know or forgets.
chmod 0755 ${LAUNCH}
export LD_LIBRARY_PATH="${LIBRARY}:${LD_LIBRARY_PATH}"
cd ${HOME}

kill_sense &
stickmod -c /storage/pico/dpadmouse.cfg &
sleep 1

${LAUNCH} -root_path ${GAME_DIR} -joystick 0 ${OPTIONS} "${CART}"

pkill -9 kill_sense
pkill -9 stickmod

shopt -s nocasematch
if [[ "${1}" == *splore* ]]; then

# copy downloader games to roms folder
for file in /storage/pico/.lexaloffle/pico-8/bbs/carts/*.p8.png; do
    base_name="$(basename "$file" .p8.png)"
    roms="/storage/roms/pico-8/$base_name"
    images="/storage/roms/pico-8/images/$base_name"

    if [ ! -e "$roms.p8" ]; then
        cp "$file" "$roms.p8"
        cp "$file" "$images.png"
		if ! xmlstarlet sel -t -v "//gameList/game[path='./$base_name.p8']" "$GAMELIST" | grep -q .; then
        xmlstarlet ed --inplace \
          --subnode "/gameList" --type elem -n game -v "" \
          --subnode "/gameList/game[last()]" --type elem -n path -v "./$base_name.p8" \
          --subnode "/gameList/game[last()]" --type elem -n name -v "$base_name" \
          --subnode "/gameList/game[last()]" --type elem -n image -v "./images/$base_name.png" \
          "$GAMELIST"
        fi
    fi
done

    sync

    touch /storage/roms/pico-8/gamelist.xml
    #swaymsg exit
    sleep 1
    #systemctl restart emustation
fi
shopt -u nocasematch
