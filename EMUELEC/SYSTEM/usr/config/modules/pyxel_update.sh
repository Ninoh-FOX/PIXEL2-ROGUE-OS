#!/bin/sh
. /etc/profile

sh -c 'echo -e "\033c" > /dev/tty2'

chvt 2

python3 -m pip install --user --upgrade --no-cache-dir --no-compile --force-reinstall pip   > /dev/tty2 2>&1
python3 -m pip install --user --upgrade --no-cache-dir --no-compile --force-reinstall pyxel > /dev/tty2 2>&1
swaymsg exit
sleep 3
swaymsg restart
systemctl restart emustation
