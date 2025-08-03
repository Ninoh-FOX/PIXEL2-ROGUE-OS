#!/bin/bash

source /etc/profile

if [ ! -d /storage/.config/scraper ]; then
   mkdir /storage/.config/scraper
fi

set_kill set "python3"
HOME=/storage
clear

python3 /usr/bin/scraper.py > /storage/.config/scraper/log.txt 2>&1
sync
