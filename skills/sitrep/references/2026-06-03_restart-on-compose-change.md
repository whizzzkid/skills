---
class: principle
---

- **Rule:** After a `docker-compose.yml` change in `$SITREP_REPO` is pushed, run `docker compose down && docker compose up -d` and confirm via `docker compose logs --tail=5`.
- **Why:** Committing a compose change without restarting leaves the running container out of sync with the committed config.
- **Where:** "HARD RULE — restart SilverBullet after a compose change"; `Bash(docker compose:*)` added to allowed-tools.
