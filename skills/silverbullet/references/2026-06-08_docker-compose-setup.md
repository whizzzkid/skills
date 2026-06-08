---
class: principle
---

- **Rule:** Run SilverBullet via docker-compose with empty `SB_USER=` (no auth)
  bound to `127.0.0.1` only, and a pinned image tag (never `latest`).
- **Why:** Empty `SB_USER` disables auth (correct for local-only); a `0.0.0.0`
  bind without auth exposes the workspace; `latest` drifts across breaking
  minor versions.
- **Where:** "Local Setup (docker-compose)" section.
