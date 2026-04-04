# local.d directory

Configuration fragments included by `unbound.conf` via `include:` directives.

| File | Purpose | Updated by |
|------|---------|-----------|
| `doh-local.conf` | Local DNS zone for DoH endpoint (`doh.lan`) | Static |
| `unbound_add_servers.conf` | Ad and tracker blocking list (~3500 domains) | `update-unbound-ads.timer` (weekly) |

---

## doh-local.conf

Defines a static local zone for the internal DoH server (Caddy):

```
local-zone: "lan." static
local-data: "doh.lan. IN A 127.0.0.1"
local-data: "doh.lan. IN AAAA ::1"
```

This allows browsers configured with ECH and DoH to resolve `doh.lan` locally without hitting upstream DNS.

---

## unbound_add_servers.conf

Downloaded weekly from [pgl.yoyo.org](https://pgl.yoyo.org/adservers/) in Unbound format.  
Deployed and reloaded automatically by `update-unbound-ads.service`.

Do not edit manually — it is overwritten on each update.
