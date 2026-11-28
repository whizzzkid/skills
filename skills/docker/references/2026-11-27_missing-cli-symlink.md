---
class: principle
skill: wk-docker
date: 2026-11-27
severity: medium
---

# Installed-but-unlinked CLI: prefix the keg bin, never reinstall

**Rule** — `docker` not found while the package manager lists the formula installed → list the keg's `bin` directory
before any install. Run the one command with that `bin` prepended to PATH and tell the user that relinking the
formula is the permanent fix.

**Why** — The binary existed in the keg; only its prefix-bin symlink was missing (sibling helpers such as compose and
credential helpers were still linked). A reinstall or relink mutates the host for a fault a per-command PATH prefix
avoids. Verified by listing the keg bin and the prefix bin.

**Where** — `SKILL.md` → Pre-Flight Checks → CLI on PATH (macOS).

**Superseded** — the pre-flight's unconditional `|| brew link docker` (2026-06-23 reference): relinking is now the
user-told permanent fix, not an automatic step. The link-conflict dry-run path still applies when linking is chosen.
