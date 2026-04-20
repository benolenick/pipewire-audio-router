# pipewire-audio-router

Route specific apps to specific audio sinks on PipeWire/PulseAudio automatically.

Uses `pactl subscribe` to watch for new audio streams and moves them to the right sink as soon as they appear — no WirePlumber rules required.

## Setup

**1. Find your sink names:**
```bash
pactl list sinks short
```

**2. Edit `audio-router.sh`** — set `SINK_A` and `SINK_B` to your device names, and update the `route_streams()` awk block with your app names (`application.name` values from `pactl list sink-inputs`).

**3. Install:**
```bash
cp audio-router.sh ~/.local/bin/audio-router.sh
chmod +x ~/.local/bin/audio-router.sh
mkdir -p ~/.config/systemd/user
cp audio-router.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now audio-router.service
```

**4. Check it's running:**
```bash
systemctl --user status audio-router.service
```

## Finding app names

```bash
pactl list sink-inputs | grep application.name
```

## Requirements

- PipeWire or PulseAudio with `pactl`
- bash
