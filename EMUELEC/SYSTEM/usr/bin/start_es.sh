#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

### setup is the same
. $(dirname $0)/es_settings

clear
show /usr/local/share/splash/splash.png &
sleep 1

emulationstation --log-path /var/log --no-splash

pkill -9  show
