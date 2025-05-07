#!/bin/bash

. /etc/profile
set_kill set "-9 fbneo"

rom_name=$(basename "$1" .zip)

FBNEO_LOG="/var/log/fbneo.log"
FBNEO_CONFIG="/storage/.config/fbneo"
FBNEO_LOCAL="/storage/.local/share"
FBNEO_CONFIG_INI="/storage/.local/share/fbneo/config/fbneo.ini"
FBNEO_PATH="/usr/local/share/fbneo"
VSYNC=$(get_setting Video_Sync fbn fbneosa)
SCALE=$(get_setting Integerscale fbn fbneosa)
VFILTRE=$(get_setting Video_Filtre fbn fbneosa)
FULLSCREEN=$(get_setting Fullscreen fbn fbneosa)
STRETCH=$(get_setting Stretch_screen fbn fbneosa)
SCANLINES=$(get_setting Scanlines fbn fbneosa)
GAMMA=$(get_setting Gamma_fixer fbn fbneosa)
OPTIONS="-joy"

control-gen_init.sh
source /storage/.config/gptokeyb/control.ini
get_controls

if [ ! -d "$FBNEO_CONFIG" ]; then
  mkdir "$FBNEO_CONFIG"
  cp $FBNEO_PATH/fbneo.gptk "$FBNEO_CONFIG"
  sync
fi

if [ ! -f "$FBNEO_CONFIG_INI" ]; then
  mkdir "$FBNEO_LOCAL/fbneo"
  cp -r "/usr/config/fbneo" "$FBNEO_LOCAL"
  sync
fi

#set screenshots link

if [ ! -d "$FBNEO_LOCAL/fbneo/screenshots" ]; then
  ln -sf "/storage/roms/screenshots" "$FBNEO_LOCAL/fbneo/screenshots"
  sync
fi

if [ ! -L "$FBNEO_LOCAL/fbneo/screenshots" ]; then
  if [ -d "$FBNEO_LOCAL/fbneo/screenshots" ]; then
    rm -rf "$FBNEO_LOCAL/fbneo/screenshots"
  fi
  ln -sf "/storage/roms/screenshots" "$FBNEO_LOCAL/fbneo/screenshots"
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

if [ "${STRETCH}" = "ON" ]; then
  if [ $(gpudriver) == "libmali" ]; then
  sed -i 's#nVidSelect 1$#nVidSelect 0#' "${FBNEO_CONFIG_INI}" 2>/dev/null
  else
  sed -i 's#nVidSelect 0$#nVidSelect 1#' "${FBNEO_CONFIG_INI}" 2>/dev/null
  fi
  sed -i 's#bVidFullStretch 0$#bVidFullStretch 1#' "${FBNEO_CONFIG_INI}" 2>/dev/null
  sync
elif [ "${STRETCH}" = "OFF" ]; then
  sed -i 's#nVidSelect 1$#nVidSelect 0#' "${FBNEO_CONFIG_INI}" 2>/dev/null
  sed -i 's#bVidFullStretch 1$#bVidFullStretch 0#' "${FBNEO_CONFIG_INI}" 2>/dev/null
  sync
fi

if [ "${SCANLINES}" = "ON" ]; then
  sed -i 's#bVidScanlines 0$#bVidScanlines 1#' "${FBNEO_CONFIG_INI}" 2>/dev/null
  sync
elif [ "${SCANLINES}" = "OFF" ]; then
  sed -i 's#bVidScanlines 1$#bVidScanlines 0#' "${FBNEO_CONFIG_INI}" 2>/dev/null
  sync
fi

if [ "${GAMMA}" = "ON" ]; then
  sed -i 's#bDoGamma 0$#bDoGamma 1#' "${FBNEO_CONFIG_INI}" 2>/dev/null
  sync
elif [ "${GAMMA}" = "OFF" ]; then
  sed -i 's#bDoGamma 1$#bDoGamma 0#' "${FBNEO_CONFIG_INI}" 2>/dev/null
  sync
fi

sleep 1

/usr/local/bin/fbneo ${OPTIONS} "${rom_name}" > $FBNEO_LOG 2>&1
sync

pkill -9 kill_sense
pkill -9 gptokeyb
