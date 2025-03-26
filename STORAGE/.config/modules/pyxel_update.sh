#!/bin/sh
. /etc/profile

sh -c 'echo -e "\033c" > /dev/tty2'

chvt 2

/storage/pyxel_Python/bin/pip3 install -U pip --root-user-action=ignore   > /dev/tty2 2>&1
/storage/pyxel_Python/bin/pip3 install -U pyxel --root-user-action=ignore > /dev/tty2 2>&1
swaymsg exit
sleep 3
swaymsg restart
systemctl restart emustation
