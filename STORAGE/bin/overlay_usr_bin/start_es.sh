#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

### setup is the same
. $(dirname $0)/es_settings

mpv --image-display-duration=5 -fs /storage/.config/emulationstation/resources/splash.png &
emulationstation --log-path /var/log --no-splash
