# unbound — openSUSE Tumbleweed

![Unbound](https://img.shields.io/badge/Unbound-1.x-0078D4?style=flat)
![Platform](https://img.shields.io/badge/platform-openSUSE%20Tumbleweed-73BA25?style=flat&logo=opensuse&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green?style=flat)
![DNSSEC](https://img.shields.io/badge/DNSSEC-enabled-blue?style=flat)
![DoT](https://img.shields.io/badge/DNS--over--TLS-Quad9-purple?style=flat)
![DoH](https://img.shields.io/badge/DoH-local%20via%20Caddy-00ADD8?style=flat)

Production-ready Unbound recursive DNS resolver configuration for **openSUSE Tumbleweed** — hardened, privacy-first, with DNS-over-TLS upstream (Quad9), local DoH endpoint, DNSSEC validation, ad blocking, and automated maintenance via systemd.

---

## Overview

This configuration transforms Unbound into a full privacy DNS stack serving the local host and KVM virtual machines. Upstream resolution is exclusively performed over **TLS (DoT)** to Quad9, ensuring no plaintext DNS leaves the system.

Key design goals:
- **Privacy** — QNAME minimization, hide-identity, hide-version, no query logging to upstream
- **Security** — DNSSEC validation, hardened against amplification and rebinding attacks
- **Local DoH** — serves DNS-over-HTTPS internally via Caddy (`doh.lan`) for ECH-capable browsers
- **Ad blocking** — ~3500 domains blocked at DNS level via pgl.yoyo.org (Unbound format)
- **Automation** — systemd timers maintain the ad list (weekly) and root hints (monthly)
- **Monitoring** — statistics exported to Prometheus via unbound_exporter

---

## Architecture

```
Browser (ECH)
    │
    ▼
Caddy (doh.lan:8053) ──────────────────► Unbound (127.0.0.1:53)
                                              │
                          ┌───────────────────┤
                          │                   │
                    Local zones          Forward zone "."
                    (doh.lan, bytel.fr)       │
                                         DNS-over-TLS
                                              │
                                         ┌───┴───┐
                                      Quad9   Quad9
                                    9.9.9.9  149.112.112.112
```

---

## Features

### Privacy & security
- `qname-minimisation: yes` + `qname-minimisation-strict: yes` — minimizes query exposure to authoritative servers
- `hide-identity: yes` / `hide-version: yes` — no fingerprinting of the resolver
- `use-caps-for-id: yes` — 0x20 encoding to detect forged responses
- `deny-any: yes` — blocks ANY queries used for DNS amplification attacks
- `aggressive-nsec: yes` — DNSSEC negative caching to reduce upstream load
- DNS rebinding protection — all RFC1918 ranges blocked as `private-address`
- `ratelimit: 1000` / `ip-ratelimit: 200` — protection against flood from VMs

### DNSSEC
- Full validation via `module-config: "validator iterator"`
- Auto-managed trust anchor: `/var/lib/unbound/root.key`
- `val-permissive-mode: no` — strict mode, bogus responses are rejected

### DNS-over-TLS upstream
- Exclusive TLS forwarding to **Quad9** (9.9.9.9, 149.112.112.112) on port 853
- IPv4 + IPv6 upstreams configured
- Certificate bundle: `/etc/ssl/ca-bundle.pem` (openSUSE system trust store)
- TLS cipher policy: `PROFILE=SYSTEM` (aligned to openSUSE system policy)

### Local DoH endpoint
- Unbound listens on `127.0.0.1@8053` and `::1@8053` for HTTP (no TLS downstream)
- Caddy terminates HTTPS and proxies to Unbound — resolves as `doh.lan`
- Enables ECH in LibreWolf and Chromium using a local trusted resolver

### Ad blocking
- Domain list from [pgl.yoyo.org](https://pgl.yoyo.org/adservers/) in Unbound format
- Deployed to `local.d/unbound_add_servers.conf`
- Updated weekly via systemd — see [`systemd-units/`](systemd-units/)

### Performance
- 4 threads with 8-slab caches (optimized for 4-core CPU)
- `msg-cache-size: 50m` / `rrset-cache-size: 100m`
- `prefetch: yes` + `serve-expired: yes` — low-latency cache serving
- `edns-tcp-keepalive: yes` — persistent TLS connections to Quad9

---

## Repository structure

```
unbound/
├── unbound.conf              # Main configuration (production)
├── local.d/
│   ├── README.md             # Documents each fragment
│   └── doh-local.conf        # Local zone for doh.lan
├── systemd-units/
│   ├── update-unbound-ads.service    # Weekly ad list update
│   ├── update-unbound-ads.timer
│   ├── update-unbound-roots.service  # Monthly root hints update
│   └── update-unbound-roots.timer
├── CHANGELOG.md
└── LICENSE
```

---

## Installation

### 1. Install Unbound

```bash
sudo zypper install unbound
```

### 2. Deploy configuration

```bash
sudo cp unbound.conf /etc/unbound/unbound.conf
```

Edit the following placeholders in `unbound.conf` to match your network:

| Placeholder | Replace with |
|-------------|-------------|
| `YOUR_BRIDGE_INTERFACE` | Your KVM bridge interface (e.g. `br0`) |
| `YOUR_LAN_SUBNET` | Your local network (e.g. `192.168.1.0/24`) |
| `YOUR_GATEWAY_IP` | Your router IP (e.g. `192.168.1.254`) |

### 3. Deploy local.d fragments

```bash
sudo mkdir -p /etc/unbound/local.d
sudo cp local.d/doh-local.conf /etc/unbound/local.d/
```

### 4. Generate control keys

```bash
sudo unbound-control-setup
```

### 5. Initialize DNSSEC trust anchor

```bash
sudo unbound-anchor -a /var/lib/unbound/root.key
```

### 6. Deploy systemd units

```bash
sudo cp systemd-units/*.service /etc/systemd/system/
sudo cp systemd-units/*.timer /etc/systemd/system/

sudo systemctl daemon-reload

# Enable and start timers
sudo systemctl enable --now update-unbound-ads.timer
sudo systemctl enable --now update-unbound-roots.timer

# Populate ad list and root hints immediately
sudo systemctl start update-unbound-ads.service
sudo systemctl start update-unbound-roots.service
```

### 7. Start Unbound

```bash
sudo systemctl enable --now unbound
```

### 8. Verify

```bash
# Check service status
systemctl status unbound

# Test local resolution
dig example.com @127.0.0.1

# Test DNSSEC validation
dig sigok.verteiltesysteme.net @127.0.0.1 +dnssec

# Test ad blocking
dig doubleclick.net @127.0.0.1

# Check statistics
unbound-control stats_noreset | head -20
```

---

## Automated maintenance

| Unit | Trigger | Action |
|------|---------|--------|
| `update-unbound-ads.timer` | Weekly (+ random 0–60 min delay) | Downloads pgl.yoyo.org list, reloads Unbound |
| `update-unbound-roots.timer` | Monthly (+ random 0–60 min delay) | Downloads root hints from internic.net, reloads Unbound |
| `unbound-anchor.timer` | Daily (built-in) | Updates DNSSEC root trust anchor |

All timers use `Persistent=true` — missed runs are executed at next boot.

---

## Useful commands

```bash
# Reload configuration without restart
sudo unbound-control reload

# Check current statistics
sudo unbound-control stats_noreset

# Flush specific domain from cache
sudo unbound-control flush example.com

# Check local ad blocking list size
wc -l /etc/unbound/local.d/unbound_add_servers.conf

# Monitor DNS queries live
sudo tail -f /var/log/unbound.log
```

---

## Integration

This resolver is designed to work alongside:
- **[squid-tumbleweed-config](https://github.com/crisis1er/squid-tumbleweed-config)** — Squid proxy uses Unbound as its DNS resolver (`dns_nameservers 127.0.0.1 ::1`)
- **Caddy** — terminates HTTPS for the `doh.lan` DoH endpoint, proxies to Unbound port 8053
- **Prometheus + unbound_exporter** — exposes resolver statistics for monitoring

---

## Contributing

Issues and pull requests are welcome.  
Please include your Unbound version (`unbound -V`) and openSUSE version in bug reports.

---

## License

MIT License — see [LICENSE](LICENSE) for details.
