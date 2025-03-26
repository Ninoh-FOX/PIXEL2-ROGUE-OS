#!/bin/sh

## Overlay the /usr/bin directory.
mkdir -p /storage/.tmp/usr_bin-workdir
mkdir -p /storage/.tmp/usr_local-workdir
mkdir -p /storage/bin/overlay_usr_bin
mkdir -p /storage/bin/overlay_usr_local
mkdir -p /tmp/overlay_usr_bin
mkdir -p /tmp/overlay_usr_local
mount -t overlay overlay -o lowerdir=/usr/bin,upperdir=/storage/bin/overlay_usr_bin,workdir=/storage/.tmp/usr_bin-workdir /usr/bin
mount -t overlay overlay -o lowerdir=/usr/local,upperdir=/storage/bin/overlay_usr_local,workdir=/storage/.tmp/usr_local-workdir /usr/local
