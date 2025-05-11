#!/bin/bash

### setup is the same
source /etc/profile

CONFIG_FILE="/storage/.config/system/configs/system.cfg"

set_usbgadget_function() {
  local value="$1"

  if grep -q '^usbgadget\.function=' "$CONFIG_FILE"; then
    sed -i '/^usbgadget\.function=/s/.*/usbgadget.function='"$value"'/' "$CONFIG_FILE"
  else
    echo "usbgadget.function=$value" >> "$CONFIG_FILE"
  fi
}

if [ ! -f "/storage/.config/.switcher" ]; then
  cp /usr/bin/scraper/emulationstation /storage/bin/overlay_usr_bin/emulationstation
  touch /storage/.config/.switcher
  set_usbgadget_function "disabled"
else
  rm /storage/bin/overlay_usr_bin/emulationstation
  rm /storage/.config/.switcher
  set_usbgadget_function "mtp"
fi

/usr/bin/show /usr/local/share/splash/reboot.png &

sleep 1

sync

reboot
