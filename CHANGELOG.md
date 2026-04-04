# Changelog

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
