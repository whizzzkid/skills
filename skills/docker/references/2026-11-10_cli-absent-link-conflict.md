---
class: principle
source: learnings/skills/sitrep/2026-11-10_docker-cli-unlinked.learned.md
date: 2026-11-10
skill: wk-docker
---

# A missing CLI is not a daemon fault; dry-run a conflicting link

**Rule** — Resolve `command -v docker` before any daemon check or runtime start. `brew link docker` refused because
another formula owns its target paths → `brew list docker` to confirm the install, then
`brew link --overwrite --dry-run docker`; overwrite for real only when every listed path is a duplicate (such as shell
completions), else report the list to the user.

**Why** — `docker info` fails the same way with no CLI as with a stopped daemon, so a daemon-first check sends the run
into a runtime start that Colima refuses without the CLI. A plain `brew link` cannot succeed while a stale sibling
package holds the target paths, and a blind `--overwrite` could clobber files that are not duplicates.

**Where** — `SKILL.md` → Pre-Flight Checks → CLI on PATH (macOS).
