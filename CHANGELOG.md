# Changelog

---

## [2.4.1] — 2026-05-06

### Fixed
- `unbound.conf` — include order corrected: `zzz-overrides.conf` now loads **after** OISD
  (`unbound_add_servers.conf`) so that `transparent` overrides properly supersede `always_null`
  (Unbound keeps the last definition — earlier order was silently ineffective)
- `local.d/zzz-overrides.conf` — new file: Google admin UI `transparent` overrides extracted
  from `custom-blocks.conf` and placed in a dedicated file loaded last, ensuring OISD does not
  re-block `analytics.google.com`, `tagmanager.google.com`, `search.google.com`
- `local.d/custom-blocks.conf` — removed duplicate `gumgum.com` entry (already covered by OISD)
  and moved Google admin UI overrides to `zzz-overrides.conf`

---

## [2.4] — 2026-04-30

### Added
- `local.d/custom-blocks.conf` — IPv6 (`AAAA ::1`) coverage on every blocked domain
  - Previous entries returned `127.0.0.1` (IPv4) only — IPv6-first clients (browsers using AAAA-only)
    bypassed the block silently. Now every entry returns both `127.0.0.1` and `::1`.
- `local.d/custom-blocks.conf` — 21 new manually blocked tracker / ad-server domains:
  - **Ad networks**: `doubleclick.net`, `ad.doubleclick.net`, `googleadservices.com`,
    `amazon-adsystem.com`, `adform.net`, `adservice.google.com`, `adnxs.com`,
    `rubiconproject.com`, `2mdn.net`, `outbrain.com`, `taboola.com`, `gumgum.com`
  - **Trackers / measurement**: `google-analytics.com`, `googletagmanager.com`,
    `scorecardresearch.com`, `everesttech.net`, `demdex.net`, `bluekai.com`,
    `crwdcntrl.net`, `fullstory.com`, `optimizely.com`
  - **Anti-adblock**: `blockadblock.com`
- `local.d/custom-blocks.conf` — Google admin UI whitelist (3 `transparent` overrides)
  - `analytics.google.com`, `tagmanager.google.com`, `search.google.com` — overrides OISD blocking
    so Search Console, Google Analytics admin UI, and Tag Manager admin UI work normally
  - **Distinction preserved**: tracker domains (`www.google-analytics.com`, `googletagmanager.com`)
    remain blocked via redirect — only the first-party admin UIs are unblocked

### Changed
- `local.d/custom-blocks.conf` — formatting cleaned up: removed leading indentation on directives
  for better readability

---

## [2.3] — 2026-04-24

### Changed
- `systemd-units/update-unbound-ads.service` — now calls `scripts/update-unbound-ads.sh` instead of direct curl
  - Switched from Peter Lowe (~3,500 domains) to OISD Full (~329,000 domains)
  - All blocked domains return `127.0.0.1` instead of `0.0.0.0`
- `local.d/custom-blocks.conf` — all entries converted from `always_null` to `redirect + local-data A 127.0.0.1`
  - Added 10 new manual blocks (bnc.lt, kochava.com, clevertap-prod.com, greatis.com, cookielaw.org,
    privacy-mgmt.com, zenaps.com, partnerstack.com, s.youtube.com, ngfts.lge.com)
  - Removed `unityads.unity3d.com` (now covered by OISD Full)

### Added
- `scripts/update-unbound-ads.sh` — download + convert OISD Full blocklist
  - Converts `always_null` → `redirect + local-data A 127.0.0.1` via inline Python
  - Rationale: `always_null` returns `0.0.0.0` — ambiguous across OSes and known browser exploit vector
    ("0.0.0.0 Day" 2024 — SSRF bypass via DNS response). `127.0.0.1` returns loopback universally.

### Security
- Eliminated `0.0.0.0` from all DNS block responses — all 328,922 OISD entries now return `127.0.0.1`

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
