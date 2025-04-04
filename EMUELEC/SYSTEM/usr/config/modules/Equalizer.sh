#!/bin/sh

ALSASINK="alsa_output._sys_devices_platform_rk817-sound_sound_card0.stereo-fallback"
EFFECTSINK="effect_input.eq6"
DEFSINK=`pactl get-default-sink`
if [ "${DEFSINK}" == "${ALSASINK}" ]
then
  pactl set-sink-volume "${ALSASINK}" 100%
  volume 100
  pactl set-default-sink "${EFFECTSINK}"
  pactl set-sink-volume "${EFFECTSINK}" 50%
  volume 50
  echo EQ ON
elif [ "${DEFSINK}" == "${EFFECTSINK}" ]
then
  pactl set-default-sink "${ALSASINK}"
  pactl set-sink-volume "${ALSASINK}" 50%
  volume 50
  echo EQ OFF
fi
