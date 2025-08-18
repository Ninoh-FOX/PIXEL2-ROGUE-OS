#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

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

/storage/iux/thisui
