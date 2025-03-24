#!/bin/sh

## Overlay the /usr/bin directory.
mkdir -p /storage/.tmp/usr-workdir
mkdir -p /storage/bin/overlay_usr
mkdir -p /tmp/overlay_usr
mount -t overlay overlay -o lowerdir=/usr,upperdir=/storage/bin/overlay_usr,workdir=/storage/.tmp/usr-workdir /usr
