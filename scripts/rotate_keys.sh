#!/usr/bin/env bash
set -euo pipefail

KEY_DIR="$HOME/.ds-vnc/keys"
rm -f "$KEY_DIR/host_key" "$KEY_DIR/host_key.pub" "$KEY_DIR/client_key" "$KEY_DIR/client_key.pub"
python3 "$(dirname "$0")/../security/generate_keys.py"
echo "Keys rotated."
