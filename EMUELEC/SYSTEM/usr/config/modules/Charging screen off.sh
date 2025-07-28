#!/bin/bash

. /etc/profile

EVENTLOG="/var/log/powersave_charger.log"

# Función para detectar estado del cargador
charger_connected() {
    local status
    status=$(cat /sys/class/power_supply/battery/status 2>/dev/null)
    [ "$status" = "Charging" ]
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

# Funciones para controlar volumen según tu configuración
volume_mute() {
    local mixer=${DEVICE_AUDIO_MIXER:-Master}
    amixer -c 0 -M set "${mixer}" 0% >${EVENTLOG} 2>&1
    log $0 "Volume muted"
}

volume_restore() {
    local mixer=${DEVICE_AUDIO_MIXER:-Master}
    local vol=$(get_setting "audio.volume" 2>/dev/null)
    if [ -n "$vol" ]; then
        amixer -c 0 -M set "${mixer}" "${vol}%" >${EVENTLOG} 2>&1
        log $0 "Volume restored to ${vol}%"
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
if ! charger_connected; then
    log $0 "Cargador no conectado. Saliendo del script."
    exit 0
fi

log $0 "Cargador conectado. Aplicando powersave, apagando pantalla y sonido."

hw_display_off
volume_mute
set_powersave

log $0 "Entrando en bucle de monitorización hasta desconectar cargador..."

while charger_connected; do
    sleep 5
done

log $0 "Cargador desconectado. Restaurando volumen, pantalla y governors."

volume_restore
hw_display_on
restore_governors

log $0 "Restauración completa. Saliendo."

exit 0
