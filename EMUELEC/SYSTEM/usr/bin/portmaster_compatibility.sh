#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
. /etc/os-release

if [[ "${UI_SERVICE}" =~ sway ]]; then
  if glxinfo | grep -i "opengl renderer" | grep -q "Panfrost"; then
    if [[ "${HW_DEVICE}" =~ "RK3326" ]]; then

      for libdir in /storage/roms/ports/*/lib*; do
        portdir="$(dirname "$libdir")"
        backup_dir="$portdir/bak.libs/$(basename "$libdir")"

        mkdir -p "$backup_dir"

        find "$libdir" -maxdepth 1 -type f \( -name 'libEGL*.so*' -o -name 'libGL*.so*' \) | while read -r libfile; do
          mv "$libfile" "$backup_dir/"
        done
      done

      for port in /storage/roms/ports/*.sh; do
        sed -i '/^export SDL_VIDEO_GL_DRIVER/c\#export SDL_VIDEO_GL_DRIVER' "$port"
        sed -i '/^export SDL_VIDEO_EGL_DRIVER/c\#export SDL_VIDEO_EGL_DRIVER' "$port"
        sed -i '/get_controls && export/c\get_controls' "$port"
        echo Fixing: "$port";
      done
    fi

  else
    for backup in /storage/roms/ports/*/bak.libs/*; do
      portdir="$(dirname "$(dirname "$backup")")"
      origlibdir="$portdir/$(basename "$backup")"

      mkdir -p "$origlibdir"

      mv "$backup"/* "$origlibdir/" 2>/dev/null
      rmdir "$backup" 2>/dev/null
    done

    find /storage/roms/ports/*/bak.libs -type d -empty -delete 2>/dev/null

    for port in /storage/roms/ports/*.sh; do
      sed -i 's/^#export SDL_VIDEO_GL_DRIVER/export SDL_VIDEO_GL_DRIVER/' "$port"
      sed -i 's/^#export SDL_VIDEO_EGL_DRIVER/export SDL_VIDEO_EGL_DRIVER/' "$port"
      sed -i 's/^get_controls$/get_controls \&\& export SDL_VIDEO_GL_DRIVER/' "$port"
      echo Fixing: "$port";
    done
  fi
fi
