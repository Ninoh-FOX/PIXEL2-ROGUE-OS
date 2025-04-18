#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
. /etc/os-release

#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
. /etc/os-release

if [[ "${UI_SERVICE}" =~ sway ]]; then
  if glxinfo | grep -i "opengl renderer" | grep -q "Panfrost"; then
    for libdir in /storage/roms/ports/*/lib*; do
      portdir="$(dirname "$libdir")"
      backup_dir="$portdir/bak.libs/$(basename "$libdir")"
      mkdir -p "$backup_dir"

      find "$libdir" -maxdepth 1 -type f \( -name 'libEGL*.so*' -o -name 'libGL*.so*' \) | while read -r libfile; do
        mv "$libfile" "$backup_dir/"
      done
    done

    for port in /storage/roms/ports/*.sh; do
      sed -i 's/^export SDL_VIDEO_GL_DRIVER/#export SDL_VIDEO_GL_DRIVER/' "$port"
      sed -i 's/^export SDL_VIDEO_EGL_DRIVER/#export SDL_VIDEO_EGL_DRIVER/' "$port"
      sed -i 's/^get_controls && export.*/get_controls/' "$port"

      grep -q '^#export SDL_VIDEO_GL_DRIVER' "$port" && ! grep -A1 '^#export SDL_VIDEO_GL_DRIVER' "$port" | grep -q 'echo "GL fixed"' && \
        sed -i '/^#export SDL_VIDEO_GL_DRIVER/a echo "GL fixed"' "$port"

      grep -q '^#export SDL_VIDEO_EGL_DRIVER' "$port" && ! grep -A1 '^#export SDL_VIDEO_EGL_DRIVER' "$port" | grep -q 'echo "GL fixed"' && \
        sed -i '/^#export SDL_VIDEO_EGL_DRIVER/a echo "GL fixed"' "$port"

      echo Fixing: "$port"
    done

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

      sed -i '/^export SDL_VIDEO_GL_DRIVER/{n;/^echo "GL fixed"/d;}' "$port"
      sed -i '/^export SDL_VIDEO_EGL_DRIVER/{n;/^echo "GL fixed"/d;}' "$port"

      sed -i 's/^get_controls$/get_controls \&\& export SDL_VIDEO_GL_DRIVER/' "$port"

      echo Fixing: "$port"
    done
  fi
fi
