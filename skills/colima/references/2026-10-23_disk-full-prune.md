---
class: principle
source: learnings/skills/colima/2026-10-23_disk-full-prune.learned.md
date: 2026-10-23
skill: wk-colima
---

**Rule** — An out-of-space error during a container build means the fixed-size VM disk is full. Check
`docker system df`, prune build cache (`docker builder prune -af`) and dangling images (`docker image prune -f`), then
retry. Never prune volumes.

**Why** — Build cache and dangling images accumulate on the VM disk until a build step (a package install) fails for
space. A restart reclaims nothing. Volumes hold database data shared across worktrees, so a volume prune destroys state
other branches depend on.

**Where** — `SKILL.md` → "Disk full" section before Step 5; `allowed-tools`; README Key Behavior.
