#!/bin/sh
modprobe hci_uart  #加载驱动

killall brcm_patchram_plus
echo 0 > /sys/class/rfkill/rfkill0/state # 下电
sleep 2
echo 1 > /sys/class/rfkill/rfkill0/state # 上电
sleep 2

brcm_patchram_plus --enable_hci --no2bytes --use_baudrate_for_download --tosleep 200000 --baudrate 1500000 --patchram /etc/firmware/xxx.hcd /dev/ttyS1 &