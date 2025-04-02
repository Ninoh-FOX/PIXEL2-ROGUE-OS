#!/bin/sh

.  /etc/profile
export SDL_GAMECONTROLLERCONFIG_FILE=/usr/config/SDL-GameControllerDB/gamecontrollerdb.txt
export HOTKEY=back
export SDL_VIDEO_GL_DRIVER=/usr/lib/egl/libGL.so.1
export LIBRARY_PATH="/usr/lib32"
export LD_LIBRARY_PATH="/storage/.config/.picoarch/lib:${LIBRARY_PATH}"
export SPA_PLUGIN_DIR="${LIBRARY_PATH}/spa-0.2"
export PIPEWIRE_MODULE_DIR="${LIBRARY_PATH}/pipewire-0.3/"
export LIBGL_DRIVERS_PATH="${LIBRARY_PATH}/dri"
export SDL_GAMECONTROLLERCONFIG="19008d96010000000221000000010000,pixel2_joypad,platform:Linux,x:b2,a:b1,b:b0,y:b3,guide:b14,back:b8,start:b9,dpleft:b12,dpdown:b11,dpright:b13,dpup:b10,leftshoulder:b4,lefttrigger:b6,rightshoulder:b5,righttrigger:b7,"

/storage/bin/111-sway-init
swaymsg reload

gptokeyb "picoarch_plumOS" -c /storage/.config/.picoarch/data/default.gptk &
PICOARCH_DIR="/storage/.config/.picoarch"
PICOARCH_LD="${PICOARCH_DIR}/bin/picoarch_plumOS_LD"
PICOARCH_HD="${PICOARCH_DIR}/bin/picoarch_plumOS_HD"
PICOARCH_720="${PICOARCH_DIR}/bin/picoarch_plumOS_720"
PICOARCH_1024="${PICOARCH_DIR}/bin/picoarch_plumOS_1024"
ROM="${1}"
CORE="${PICOARCH_DIR}/cores/${2}_libretro.so"
EMULATOR="${3}"

if [ "${EMULATOR}" = "picoarch_LD" ];then
        "${PICOARCH_LD}" "${CORE}" "${ROM}"
		kill -9 $(pidof gptokeyb)
elif [ "${EMULATOR}" = "picoarch_HD" ];then
        "${PICOARCH_HD}" "${CORE}" "${ROM}"
		kill -9 $(pidof gptokeyb)
elif [ "${EMULATOR}" = "picoarch_720" ];then
        "${PICOARCH_720}" "${CORE}" "${ROM}"
        kill -9 $(pidof gptokeyb)
elif [ "${EMULATOR}" = "picoarch_1024" ];then
        "${PICOARCH_1024}" "${CORE}" "${ROM}"
        kill -9 $(pidof gptokeyb)
fi
kill -9 $(pidof gptokeyb)
