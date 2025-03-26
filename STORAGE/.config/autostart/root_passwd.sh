#!/bin/sh

touch /storage/.cache/shadow
chmod 777 /storage/.cache/shadow
echo "root:dummy:::::::" > /storage/.cache/shadow

ROOT_PASS="`grep "^root.password=" /storage/.config/system/configs/system.cfg | awk -F= '{print $NF}'`"
setrootpass "${ROOT_PASS}"
systemctl restart sshd
