#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
. /etc/os-release

set_kill set "-9 drastic"

#load gptokeyb support files
control-gen_init.sh
source /storage/.config/gptokeyb/control.ini
get_controls

#Copy drastic files to .config
if [ ! -d "/storage/drastic" ]; then
  mkdir -p /storage/drastic/
  cp -r /usr/local/share/drastic/* /storage/drastic/
fi

if [ ! -d "/storage/drastic/system" ]; then
  mkdir -p /storage/drastic/system
fi

for bios in nds_bios_arm9.bin nds_bios_arm7.bin
do
  if [ ! -e "/storage/drastic/system/${bios}" ]; then
     if [ -e "/storage/roms/bios/${bios}" ]; then
       ln -sf /storage/roms/bios/${bios} /storage/drastic/system
     fi
  fi
done

#Make drastic savestate folder
if [ ! -d "/storage/roms/savestates/nds" ]; then
  mkdir -p /storage/roms/savestates/nds
fi

#Link savestates to roms/savestates/nds
rm -rf /storage/drastic/savestates
ln -sf /storage/roms/savestates/nds /storage/drastic/savestates

#Link saves to roms/nds/saves
rm -rf /storage/drastic/backup
ln -sf /storage/roms/nds /storage/drastic/backup

cd /storage/drastic/

export HOME=/storage/drastic
export LD_LIBRARY_PATH=lib:$LD_LIBRARY_PATH

sv=`cat /proc/sys/vm/swappiness`
echo 10 > /proc/sys/vm/swappiness

kill_sense &
./runner &
sleep 1
SDL_VIDEODRIVER=NDS ./drastic "$1" > std.log 2>&1
sync

pkill -9 kill_sense
pkill -9 runner

echo $sv > /proc/sys/vm/swappiness
