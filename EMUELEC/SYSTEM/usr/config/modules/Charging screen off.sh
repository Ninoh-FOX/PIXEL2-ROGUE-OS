#!/bin/bash

. /etc/profile

EVENTLOG="/var/log/powersave_charger.log"

# Función para detectar estado del cargador
charging() {
    local status
    status=$(cat /sys/class/power_supply/battery/status 2>/dev/null)
    [ "$status" = "Charging" ]
}

usb_connected() {
    local status
    status=$(cat /sys/class/power_supply/ac/online 2>/dev/null)
    [ "$status" = "1" ]
}

# Funciones para apagar y encender pantalla
hw_display_off() {
    wlr-randr --output DSI-1 --off 2>/dev/null
    if [ -w /sys/class/backlight/backlight/bl_power ]; then
        echo 1 > /sys/class/backlight/backlight/bl_power
    fi
    log $0 "Display turned off"
}

hw_display_on() {
    wlr-randr --output DSI-1 --on 2>/dev/null
    if [ -w /sys/class/backlight/backlight/bl_power ]; then
        echo 0 > /sys/class/backlight/backlight/bl_power
    fi
    log $0 "Display turned on"
}

# Guardar estados originales de volumen (al inicio del script, antes de mutear)
ORIG_HEADPHONE_STATE=$(amixer -c 0 get Headphone | awk -F'[][]' '/Playback.*\[on\]|\[off\]/ {print $2; exit}')
ORIG_SPEAKER_STATE=$(amixer -c 0 get Speaker   | awk -F'[][]' '/Playback.*\[on\]|\[off\]/ {print $2; exit}')
log $0 "Estados originales: Headphone=${ORIG_HEADPHONE_STATE}, Speaker=${ORIG_SPEAKER_STATE}"

# Función para mutear volumen (siempre pone off)
volume_mute() {
    amixer -c 0 set Headphone off >"${EVENTLOG}" 2>&1
    amixer -c 0 set Speaker off >"${EVENTLOG}" 2>&1
    log $0 "Volume muted (Headphone and Speaker off)"
}

# Función para restaurar volumen al estado original
volume_restore() {
    if [ "$ORIG_HEADPHONE_STATE" = "on" ]; then
        amixer -c 0 set Headphone on >"${EVENTLOG}" 2>&1
        log $0 "Restored Headphone to ON"
    else
        amixer -c 0 set Headphone off >"${EVENTLOG}" 2>&1
        log $0 "Restored Headphone to OFF"
    fi

    if [ "$ORIG_SPEAKER_STATE" = "on" ]; then
        amixer -c 0 set Speaker on >"${EVENTLOG}" 2>&1
        log $0 "Restored Speaker to ON"
    else
        amixer -c 0 set Speaker off >"${EVENTLOG}" 2>&1
        log $0 "Restored Speaker to OFF"
    fi
}

# Guardar governors actuales sin fallback
CUR_CPU_FREQ="$(cat ${CPU_FREQ}/scaling_governor)"
CUR_GPU_FREQ="$(cat ${GPU_FREQ}/governor)"
CUR_DMC_FREQ="$(cat ${DMC_FREQ}/governor)"

log $0 "Guardados governors originales: CPU=${CUR_CPU_FREQ}, GPU=${CUR_GPU_FREQ}, DMC=${CUR_DMC_FREQ}"

# Función para restaurar governors
restore_governors() {
    set_cpu_gov "$CUR_CPU_FREQ"
    set_gpu_gov "$CUR_GPU_FREQ"
    set_dmc_gov "$CUR_DMC_FREQ"
    log $0 "Governors restaurados a: CPU=${CUR_CPU_FREQ}, GPU=${CUR_GPU_FREQ}, DMC=${CUR_DMC_FREQ}"
}

# Función para poner governors en powersave
set_powersave() {
    set_cpu_gov powersave
    set_gpu_gov powersave
    set_dmc_gov powersave
    log $0 "Governors puestos en powersave"
}

# Main script

if ! usb_connected; then
    if ! charging; then
        log $0 "Cargador no conectado. Saliendo del script."
        exit 0
    fi
fi

log $0 "Cargador conectado. Aplicando powersave, apagando pantalla y sonido."

hw_display_off
volume_mute
set_powersave

log $0 "Entrando en bucle de monitorización hasta desconectar cargador..."

while usb_connected || charging; do
    sleep 5
done

log $0 "Cargador desconectado. Restaurando volumen, pantalla y governors."

volume_restore
hw_display_on
restore_governors

log $0 "Restauración completa. Saliendo."

exit 0
