---
skill: wk-sitrep
date: 2026-06-03
type: correction
severity: medium
---

Always restart SilverBullet (docker compose down && up -d) immediately after committing a docker-compose.yml change.

**What happened:** Committed a docker-compose.yml change without restarting the container, leaving the running service out of sync with the committed config.

**Root cause:** Restart step was omitted from the commit+push flow when docker-compose.yml is the changed file.

**Suggested fix:** In wk-sitrep (and any skill that edits docker-compose.yml in $SITREP_REPO), after git push succeeds, always run `docker compose down && docker compose up -d` in the repo directory and confirm the new config is active via `docker compose logs --tail=5`.
