#!/bin/bash

. /etc/profile
set_kill set "-9 fbneo"

rom_name=$(basename "$1" .zip)

FBNEO_LOG="/var/log/fbneo.log"
FBNEO_CONFIG="/storage/.config/fbneo"
FBNEO_PATH="/usr/local/share/fbneo"

if [ ! -d "$FBNEO_CONFIG" ]; then
  mkdir "$FBNEO_CONFIG"
  cp $FBNEO_PATH/fbneo.gptk "$FBNEO_CONFIG"
  sync
fi

export SDL_GAMECONTROLLERCONFIG_FILE="$FBNEO_PATH/gamecontrollerdb.txt"

if [ $(gpudriver) == "libmali" ]; then
    export LD_LIBRARY_PATH="$FBNEO_PATH/lib":$LD_LIBRARY_PATH
fi

gptokeyb -c "$FBNEO_CONFIG/fbneo.gptk" &

/usr/local/bin/fbneo -fullscreen -joy -best "${rom_name}" "$OPTION" 2>&1> $FBNEO_LOG

pkill -9 gptokeyb
