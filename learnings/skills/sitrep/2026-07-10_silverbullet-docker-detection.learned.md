---
skill: wk-sitrep
date: 2026-07-10
type: gap
severity: low
---

Bootstrap's SilverBullet check assumes a bare CLI process; misses Docker-Compose deployments already running.

**What happened:** Step 0's `pgrep -f "silverbullet"` found nothing and `command -v silverbullet` was also absent, so the skill was about to report "SilverBullet is not installed" — but a `docker-compose.yml` in the workspace repo already ran SilverBullet in a container (`docker ps` showed it healthy on the configured port). Had to manually check `docker ps` before concluding the service was actually up.

**Root cause:** The bootstrap check only covers a locally-installed CLI (`silverbullet` binary) and never checks for a Docker-based deployment, even though the skill's own Quick Reference table documents a `docker-compose.yml` restart step elsewhere.

**Suggested fix:** Before declaring SilverBullet unavailable, also check `docker compose ps` / `docker ps --filter name=silverbullet` (or a name pattern derived from the workspace's `docker-compose.yml` if present) and treat a healthy container as equivalent to the CLI running.
