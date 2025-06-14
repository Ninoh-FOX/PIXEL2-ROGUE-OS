#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

### setup is the same
. $(dirname $0)/es_settings

if ! systemctl is-active --quiet iuxway.service; then
    systemctl start iuxway.service
	systemctl stop essway.service
fi

IMAGE=/usr/local/share/splash/splash.png

if [ $(gpudriver) == "libmali" ]; then
   mpv --image-display-duration=5 -fs ${IMAGE} &
fi

if [ $(gpudriver) == "panfrost" ]; then
   /usr/bin/show ${IMAGE} &
fi

iux
