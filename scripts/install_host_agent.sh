#!/bin/bash
set -e

BINARY_PATH=${1:-./host-agent/HostAgent}
PLIST_SOURCE=LaunchDaemons/com.example.hostagent.plist
DEST_DIR=/Library/LaunchDaemons
BIN_DEST=/usr/local/bin/host-agent

if [ ! -f "$BINARY_PATH" ]; then
  echo "Binary not found at $BINARY_PATH" >&2
  exit 1
fi

mkdir -p "$DEST_DIR"
install -m 755 "$BINARY_PATH" "$BIN_DEST"
install -m 644 "$PLIST_SOURCE" "$DEST_DIR/com.example.hostagent.plist"
launchctl load "$DEST_DIR/com.example.hostagent.plist"

echo "Host agent installed."
