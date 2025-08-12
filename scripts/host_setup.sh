#!/bin/bash
set -e

# Host Setup Script for enabling remote management and login on macOS
# This script uses Apple's `kickstart` tool to configure Remote Management
# and sets up remote login (SSH) for unattended access.
# It should be run with sudo privileges on the host Mac.

# Variables
REMOTE_USER="remoteadmin"
VNC_PASSWORD=""

usage() {
  echo "Usage: $0 [-u remote_user] [-p vnc_password]" >&2
  exit 1
}

# Parse options
while getopts "u:p:" opt; do
  case $opt in
    u) REMOTE_USER="$OPTARG" ;;
    p) VNC_PASSWORD="$OPTARG" ;;
    *) usage ;;
  esac
done

if [[ -z "$REMOTE_USER" ]]; then
  usage
fi

KICKSTART="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"

if [[ ! -x "$KICKSTART" ]]; then
  echo "kickstart utility not found. This script must be run on macOS." >&2
  exit 1
fi

# Enable Remote Management for specified user with all privileges
sudo "$KICKSTART" -activate -configure -access -on \
  -users "$REMOTE_USER" -privs -all

# Configure VNC access if password provided
if [[ -n "$VNC_PASSWORD" ]]; then
  /usr/bin/defaults write /Library/Preferences/com.apple.VNCSettings.plist \
    VNCPassword -data "$(echo -n "$VNC_PASSWORD" | xxd -p | tr -d '\n')"
  sudo "$KICKSTART" -configure -clientopts -setvnclegacy -vnclegacy yes \
    -setvncpw -vncpw "$VNC_PASSWORD"
fi

# Turn on Remote Login (SSH)
sudo systemsetup -setremotelogin on

# Enable the Remote User for SSH access
sudo dscl . -append /Groups/com.apple.access_ssh GroupMembership "$REMOTE_USER" || true

echo "Remote management and login configured for user: $REMOTE_USER"
