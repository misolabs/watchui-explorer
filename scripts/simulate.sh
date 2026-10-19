#!/bin/sh
set -eu

PROJECT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SDK_ROOT=${CONNECTIQ_SDK_ROOT:-"$HOME/Library/Application Support/Garmin/ConnectIQ/Sdks"}
DEVICE=${1:-fr165}
START_DELAY=${SIMULATOR_START_DELAY:-3}

MONKEYDO=$(find "$SDK_ROOT" -type f -path '*/bin/monkeydo' | sort | tail -n 1)
if [ -z "$MONKEYDO" ]; then
    echo "Connect IQ simulator tools not found below: $SDK_ROOT" >&2
    echo "Set CONNECTIQ_SDK_ROOT to override it." >&2
    exit 1
fi

SDK_BIN=$(dirname "$MONKEYDO")
CONNECTIQ="$SDK_BIN/connectiq"
APP="$PROJECT_DIR/bin/WatchUiExplorer.prg"

if [ ! -x "$CONNECTIQ" ]; then
    echo "Connect IQ simulator launcher not found: $CONNECTIQ" >&2
    exit 1
fi

"$PROJECT_DIR/scripts/build.sh" "$DEVICE"
"$CONNECTIQ" >/dev/null 2>&1

echo "Waiting ${START_DELAY}s for the simulator, then loading $DEVICE..."
sleep "$START_DELAY"
echo "Running WatchUi Explorer on the $DEVICE simulator (Ctrl-C to detach)"
exec "$MONKEYDO" "$APP" "$DEVICE"
