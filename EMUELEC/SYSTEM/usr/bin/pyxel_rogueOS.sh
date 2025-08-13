#!/bin/sh

. /etc/profile
. /etc/os-release

set_kill set "-15 python3"

ondemand

export SDL_GAMECONTROLLERCONFIG="19008d96010000000221000000010000,pixel2_joypad,platform:Linux,x:b2,a:b1,b:b0,y:b3,guide:b14,back:b8,start:b9,dpleft:b12,dpdown:b11,dpright:b13,dpup:b10,leftshoulder:b4,lefttrigger:b6,rightshoulder:b5,righttrigger:b7,"

kill_sense &

PYXEL_DIR="/storage/.config/.pyxel"
PYXEL_BIN="/storage/.local/bin/pyxel"
ROM="${1}"
EXTENSION=`echo "${ROM}" | awk -F. '{print $NF}'`
ROMNAME=`basename "${ROM}" | awk -F. '{print $1}'`

if [ "${EXTENSION}" = "py" ]; then
  "${PYXEL_BIN}" run "${ROM}"
elif [ "${EXTENSION}" = "pyxapp" ]; then
  "${PYXEL_BIN}" play "${ROM}"
elif [ "${EXTENSION}" = "edit" ]; then
  mkdir -p "${PYXEL_DIR}"/save
  "${PYXEL_BIN}" edit "${PYXEL_DIR}"/save/"${ROMNAME}".pyxres
  sync
else
  exit 0
fi

pkill -9 kill_sense

