#!/bin/bash
set -euo pipefail

HOST_ID="test-host-$$"
BROKER_PORT=3000
BROKER_URL="ws://localhost:${BROKER_PORT}/connect?hostId=${HOST_ID}&role=host"
CLIENT_URL="ws://localhost:${BROKER_PORT}/connect?hostId=${HOST_ID}&role=client"

KEY_DIR=$(mktemp -d)
KEY_PATH="$KEY_DIR/host_key.pub"
echo "dummy-key" > "$KEY_PATH"

# Start broker
node broker/server.js &
BROKER_PID=$!

# Start host agent
(
  cd host-agent && swift run HostAgent --host-id "$HOST_ID" --broker-url "$BROKER_URL" --key-path "$KEY_PATH"
) &
HOST_PID=$!

# Allow processes to start
sleep 2

# Run client handshake check
node scripts/client-handshake.js "$CLIENT_URL"
RESULT=$?

# Cleanup
kill $HOST_PID $BROKER_PID
rm -rf "$KEY_DIR"

exit $RESULT
