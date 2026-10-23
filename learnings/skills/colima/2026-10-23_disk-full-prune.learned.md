---
skill: wk-colima
date: 2026-10-23
type: pattern
severity: low
verified-against-source: yes
---

When apt reports "not enough free space" during a container build, the Colima VM disk is full.

**What happened:** The devcontainer build failed in apt-get, and `docker system df` showed large reclaimable build cache and images.

**Root cause:** Build cache and dangling images had accumulated on the fixed-size VM disk.

**Suggested fix:** Run `docker builder prune -af` and `docker image prune -f`, then retry. Never prune volumes, which hold DB data shared across worktrees.
