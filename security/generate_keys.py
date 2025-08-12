#!/usr/bin/env python3
import os
import subprocess
from pathlib import Path

KEY_DIR = Path.home() / '.ds-vnc' / 'keys'
HOST_KEY = KEY_DIR / 'host_key'
CLIENT_KEY = KEY_DIR / 'client_key'


def generate_key(path: Path):
    if path.exists():
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(['ssh-keygen', '-t', 'rsa', '-N', '', '-f', str(path)], check=True)
    for p in (path, Path(str(path) + '.pub')):
        os.chmod(p, 0o600)


def main():
    generate_key(HOST_KEY)
    generate_key(CLIENT_KEY)


if __name__ == '__main__':
    main()
