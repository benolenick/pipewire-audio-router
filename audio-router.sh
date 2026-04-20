#!/bin/bash
# pipewire-audio-router — route specific apps to specific sinks on PipeWire/PulseAudio
#
# Usage:
#   1. Find your sink names:  pactl list sinks short
#   2. Set SINK_A and SINK_B below to match your devices
#   3. Add app names to route_streams() as needed
#   4. Run directly or install as a systemd user service (see README)

SINK_A="bluez_output.XX_XX_XX_XX_XX_XX.1"   # e.g. Bluetooth headset
SINK_B="alsa_output.pci-0000_00_1f.3.analog-stereo"  # e.g. speakers

route_streams() {
    pactl list sink-inputs 2>/dev/null | awk '
        /^Sink Input #/ { id = substr($3, 2) }
        /application\.name = "Google Chrome"/ { print id " sink_a" }
        /application\.name = "Chromium"/       { print id " sink_a" }
        /application\.name = "Firefox"/        { print id " sink_b" }
    ' | while read id dest; do
        if [ "$dest" = "sink_a" ]; then
            pactl move-sink-input "$id" "$SINK_A" 2>/dev/null
        else
            pactl move-sink-input "$id" "$SINK_B" 2>/dev/null
        fi
    done
}

echo "[audio-router] Started"
pactl subscribe 2>/dev/null | grep --line-buffered "'new' on sink-input" | while read _; do
    sleep 0.3
    route_streams
done
