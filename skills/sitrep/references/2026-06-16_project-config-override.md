---
class: principle
skill: wk-sitrep
date: 2026-06-16
---

**Rule:** In Step 0 bootstrap, probe `.sitrep.yml` at the working repo root and
override only the keys present. Resolution order per key: `.sitrep.yml` → env
var → skill default. Run the probe before the mandatory env guards so per-project
config can supply the vars.

**Why:** Relying on env vars alone (`$SITREP_PORT`, `$SITREP_REPO`, `$EMPLOYER`)
silently produces wrong defaults for engineers who do not export them in their
shell profile — e.g. a wrong default port made every generated `open` URL and
announcement link point at the wrong host port. A repo-local config file travels
with the project and removes the hidden shell-profile dependency.

**Where:** Step 0 → Verify environment and paths.
