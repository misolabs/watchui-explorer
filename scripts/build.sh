#!/bin/sh
set -eu

PROJECT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SDK_ROOT=${CONNECTIQ_SDK_ROOT:-"$HOME/Library/Application Support/Garmin/ConnectIQ/Sdks"}
KEY_PATH=${DEVELOPER_KEY_PATH:-"$PROJECT_DIR/../garmin dev/developer_key"}
DEVICE=${1:-fr165}

if [ ! -f "$KEY_PATH" ]; then
    echo "Developer key not found: $KEY_PATH" >&2
    echo "Set DEVELOPER_KEY_PATH to override it." >&2
    exit 1
fi

MONKEYC=$(find "$SDK_ROOT" -type f -path '*/bin/monkeyc' | sort | tail -n 1)
if [ -z "$MONKEYC" ]; then
    echo "Connect IQ compiler not found below: $SDK_ROOT" >&2
    echo "Set CONNECTIQ_SDK_ROOT to override it." >&2
    exit 1
fi

mkdir -p "$PROJECT_DIR/bin"
"$MONKEYC" \
    -d "$DEVICE" \
    -f "$PROJECT_DIR/monkey.jungle" \
    -o "$PROJECT_DIR/bin/WatchUiExplorer.prg" \
    -y "$KEY_PATH"

echo "Built bin/WatchUiExplorer.prg for $DEVICE"
