#!/bin/bash
set -euo pipefail

DEST="/etc/unbound/local.d/unbound_add_servers.conf"
TMP="/tmp/oisd_raw.conf"
URL="https://big.oisd.nl/unbound"

# Download OISD Full blocklist
curl -fsSo "$TMP" "$URL"

# Convert always_null → redirect + local-data 127.0.0.1
# Rationale: always_null returns 0.0.0.0 which is ambiguous across OSes
# and has known browser exploit vectors ("0.0.0.0 Day" CVE-2024).
# redirect + local-data 127.0.0.1 returns loopback universally — ECONNREFUSED.
python3 - << 'PYEOF'
src = "/tmp/oisd_raw.conf"
dst = "/etc/unbound/local.d/unbound_add_servers.conf"

with open(src, "r") as fin, open(dst, "w") as fout:
    for line in fin:
        stripped = line.strip()
        if stripped.startswith("local-zone:") and "always_null" in stripped:
            domain = stripped.split('"')[1]
            fout.write(f'local-zone: "{domain}" redirect\n')
            fout.write(f'local-data: "{domain} A 127.0.0.1"\n')
        else:
            fout.write(line)
PYEOF

rm -f "$TMP"

systemctl restart unbound.service
