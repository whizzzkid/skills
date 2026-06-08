---
skill: wk-silverbullet
date: 2026-06-08
type: pattern
severity: medium
---

Minimal docker-compose.yml for SilverBullet: empty `SB_USER=` disables auth; bind to `127.0.0.1` to stay localhost-only.

**What happened:** SilverBullet's auth behavior is controlled entirely by the `SB_USER` env var. Setting it to a non-empty value (`SB_USER=user:password`) enables HTTP Basic Auth. Leaving it empty (`SB_USER=`) disables auth entirely — which is correct for a local personal workspace.

**Root cause / design:** SilverBullet treats an empty `SB_USER` as "no auth required." This is intentional for local-only deployments. Exposing the port without auth on a network-accessible address would be a security risk.

**Canonical working setup (no auth, localhost-only):**
```yaml
services:
  silverbullet:
    image: ghcr.io/silverbulletmd/silverbullet:2.8.1
    restart: unless-stopped
    environment:
      - SB_USER=
    volumes:
      - ./sitrep:/space
    ports:
      - "127.0.0.1:7487:3000"
```

**Key points:**
- `SB_USER=` (empty) = no authentication. Omitting the var entirely also disables auth, but explicit empty value is self-documenting.
- `SB_USER=username:password` = enables Basic Auth (only add when asked).
- `127.0.0.1:7487:3000` binds only to localhost — never use `0.0.0.0:7487:3000` without auth.
- Pin the image version (`2.8.1`) — never use `latest`; SilverBullet has breaking changes between minor versions.
- Workspace directory maps to `/space` inside the container — all files live under `./sitrep/` on the host.
- `restart: unless-stopped` keeps it running across reboots without manual intervention.
