#!/bin/bash

cd $(dirname "$0")
export HOME=/storage/pico
  
if [ "$1" == "/storage/roms/pico-8/Splore.png" ]; then

    export LD_LIBRARY_PATH="$HOME/lib1:${LD_LIBRARY_PATH}"
    stickmod -c /storage/pico/dpadmouse.cfg &
    sleep 1

    /storage/roms/bios/pico-8/pico8_64 -draw_rect 0,0,640,480 -splore -root_path /storage/roms/pico-8 -joystick 0

    pkill -9 stickmod

else

    export LD_LIBRARY_PATH="$HOME/lib2:${LD_LIBRARY_PATH}"
    stickmod -c /storage/pico/dpadmouse.cfg &
    sleep 1

    /storage/roms/bios/pico-8/pico8_64 -draw_rect 0,0,640,480 -run "$1" -root_path /storage/roms/pico-8 -joystick 0

    pkill -9 stickmod

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

