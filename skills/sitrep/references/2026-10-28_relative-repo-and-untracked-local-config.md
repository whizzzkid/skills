---
class: principle
---

# Absolute sitrep repo; untracked non-artifacts never stop rollover

**Rule** — Step 0 absolutizes `$SITREP_REPO` (relative values resolve against the `.sitrep.yml` directory, else cwd)
and never assumes it equals the git toplevel. The rollover dirty-path check stops `start` only on tracked dirty paths
outside the close-artifact allowlist; untracked non-artifacts are ignored and never staged.

**Why** — a relative path whose git root is a parent makes every `git -C "$SITREP_REPO" … "$LIVE_FILE"` resolve the
file against the wrong base. An untracked local config file at the repo root cannot enter a commit that names its
paths explicitly, so halting on it blocks `start` with no safety gain; tracked edits still stop it.

**Where** — `SKILL.md` → Step 0 and Stage 0.5; `bootstrap.md` path resolution; `missed-end-rollover.md` Detect closure.
