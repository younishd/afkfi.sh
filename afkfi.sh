#!/usr/bin/env bash
echo
echo "afkfi.sh by 0x4"
echo

xdotool version &>/dev/null || { echo "You need to install xdotool."; exit 1; }

WID=$(xdotool search --sync --onlyvisible --name Minecraft)
[ -z "$WID" ] && { echo "Failed to retrieve window id."; exit 1; }

SINKINPUT=$(pacmd list-sink-inputs | grep 'index:' | sed 's/\s*index: //' | sed $(pacmd list-sink-inputs | grep 'application.process.binary =' | grep -n 'application.process.binary = "java"' | cut -d: -f1)'q;d')
[ -z "$SINKINPUT" ] && { echo "Failed to retrieve sink input index."; exit 1; }

SINK=$(pacmd list-sink-inputs | grep 'sink:' | sed 's/\s*sink: //' | cut -d'<' -f1 | sed $(pacmd list-sink-inputs | grep 'application.process.binary =' | grep -n 'application.process.binary = "java"' | cut -d: -f1)'q;d')
[ -z "$SINK" ] && { echo "Failed to retrieve sink index."; exit 1; }

pactl list short sinks | grep -q afkfish || (pactl load-module module-combine-sink slaves="$SINK" sink_name=afkfish sink_properties=device.description="afkfi.sh" >/dev/null && pactl move-sink-input "$SINKINPUT" afkfish)

xdotool windowactivate --sync "$WID" && xdotool key --window "$WID" Escape && sleep 0.5 && xdotool click --window "$WID" 3

while :; do
    PEAK=$(parec -d afkfish.monitor --channels=1 --latency=2 2>/dev/null | od -N2 -td2 | head -n1 | cut -d' ' -f2- | tr -d ' ')
    if [ "$PEAK" -ge 100 -o "$PEAK" -le -100 ]; then
        echo "Blub blub blub...oo0O"
        xdotool windowactivate --sync "$WID" && xdotool click --window "$WID" --repeat 2 --delay 1000 3 && sleep 1
        sleep 0.1
    else
        echo "Zzzz..."
    fi
done
