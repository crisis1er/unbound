# Changelog

---

## [2.2] — 2026-04-24

### Added
- `local.d/custom-blocks.conf` — manual blocklist file, separate from pgl.yoyo.org list (survives updates)
  - `unityads.unity3d.com` — blocks all Unity Ads subdomains (webview, configv2, etc.)
  - `cookiebot.com` — blocks Cookiebot/Cybot consent tracking CDN
- `logrotate.d/unbound` — logrotate configuration for `/var/log/unbound.log`

### Changed
- `unbound.conf` — added `include` for `local.d/custom-blocks.conf`
- `logrotate.d/unbound` — fixed `postrotate`: replaced `systemctl reload unbound` with `unbound-control log_reopen`
  - Previous behavior caused Unbound to keep writing to the rotated file after log rotation, resulting in empty log file read by Alloy/Loki (no data in Grafana live panels)

---

## [2.1] — 2026-04-06

### Added
- IPv6 LAN access-control for KVM guest DNS resolution over bridge network
- Allows KVM guests to use Unbound as IPv6 DNS resolver (placeholder: `YOUR_LAN_IPV6_PREFIX/64`)
- Previously only IPv4 LAN was explicitly allowed — IPv6 guests were refused

---

## [2.0] — 2026-04-04

### Added
- Full production `unbound.conf` with detailed inline comments
- DoH endpoint support (`doh.lan`) via `local.d/doh-local.conf`
- `systemd-units/` — 4 units for automated maintenance:
  - `update-unbound-ads` (service + weekly timer) — ad blocking list via pgl.yoyo.org
  - `update-unbound-roots` (service + monthly timer) — root hints via internic.net
- `local.d/README.md` — documents each configuration fragment
- `CHANGELOG.md`, `LICENSE`

### Changed
- Repository restructured: old files removed, proper directory layout
- README rewritten in professional English

### Removed
- `unbound_conf` — replaced by `unbound.conf`
- `unbound_installation` — Debian/apt based, not relevant
- `unbound_squid_service_timer.txt` — replaced by proper systemd unit files
- `script_update_roothints_serverlist` — replaced by systemd service

---

## [1.0] — 2025

### Added
- Initial repository — basic Unbound installation notes (Debian-oriented)
- Draft systemd units for ad list and root hints updates
- Update script for root hints and pgl.yoyo.org server list
