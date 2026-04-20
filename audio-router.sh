#!/bin/bash
# Auto-route audio: Chrome→headset, Firefox→speakers
HEADSET="bluez_output.XX_XX_XX_XX_XX_XX.1"   # replace with your headset's MAC
SPEAKERS="alsa_output.pci-0000_00_1f.3.analog-stereo"  # replace with your speakers sink

route_streams() {
    pactl list sink-inputs 2>/dev/null | awk '
        /^Sink Input #/ { id = substr($3, 2) }
        /application\.name = "Google Chrome"/ { print id " headset" }
        /application\.name = "Chromium"/ { print id " headset" }
        /application\.name = "Firefox"/ { print id " speakers" }
    ' | while read id dest; do
        if [ "$dest" = "headset" ]; then
            pactl move-sink-input "$id" "$HEADSET" 2>/dev/null
        else
            pactl move-sink-input "$id" "$SPEAKERS" 2>/dev/null
            pactl set-sink-input-volume "$id" 100% 2>/dev/null
        fi
    done
}

echo "[audio-router] Started — Chrome→headset, Firefox→speakers"
pactl subscribe 2>/dev/null | grep --line-buffered "'new' on sink-input" | while read _; do
    sleep 0.3
    route_streams
done
