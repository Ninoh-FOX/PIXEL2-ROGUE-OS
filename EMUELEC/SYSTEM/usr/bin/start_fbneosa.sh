#!/bin/bash

. /etc/profile
set_kill set "-9 fbneo"

rom_name=$(basename "$1" .zip)

FBNEO_LOG="/var/log/fbneo.log"
FBNEO_CONFIG="/storage/.config/fbneo"
FBNEO_PATH="/usr/local/share/fbneo"
VSYNC=$(get_setting Video_Sync fbn fbneosa)
SCALE=$(get_setting Integerscale fbn fbneosa)
VFILTRE=$(get_setting Video_Filtre fbn fbneosa)
FULLSCREEN=$(get_setting Fullscreen fbn fbneosa)
OPTIONS="-joy"

control-gen_init.sh
source /storage/.config/gptokeyb/control.ini
get_controls

if [ ! -d "$FBNEO_CONFIG" ]; then
  mkdir "$FBNEO_CONFIG"
  cp $FBNEO_PATH/fbneo.gptk "$FBNEO_CONFIG"
  sync
fi

export SDL_GAMECONTROLLERCONFIG_FILE="$FBNEO_PATH/gamecontrollerdb.txt"

if [ $(gpudriver) == "libmali" ]; then
    export LD_LIBRARY_PATH="$FBNEO_PATH/lib":$LD_LIBRARY_PATH
fi

kill_sense &
gptokeyb -c "$FBNEO_CONFIG/fbneo.gptk" &

if [ "${VSYNC}" = "OFF" ]
then
  OPTIONS="${OPTIONS} -novsync"
fi

if [ "${FULLSCREEN}" = "ON" ]
then
  OPTIONS="${OPTIONS} -fullscreen"
fi

if [ "${SCALE}" = "ON" ]
then
  OPTIONS="${OPTIONS} -integerscale"
fi

if [ "${VFILTRE}" = "NEAREST" ]; then
  OPTIONS="${OPTIONS} -nearest"
elif [ "${VFILTRE}" = "LINEAR" ]; then
  OPTIONS="${OPTIONS} -linear"
elif [ "${VFILTRE}" = "BEST" ]; then
  OPTIONS="${OPTIONS} -best"
fi

/usr/local/bin/fbneo ${OPTIONS} "${rom_name}" 2>&1> $FBNEO_LOG

pkill -9 kill_sense
pkill -9 gptokeyb
