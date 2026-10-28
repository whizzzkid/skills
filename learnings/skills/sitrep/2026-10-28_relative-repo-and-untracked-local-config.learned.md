---
skill: wk-sitrep
date: 2026-10-28
type: gap
severity: low
verified-against-source: n/a
---

Relative `sitrep_repo` and untracked local config files are unaddressed by bootstrap and rollover.

**What happened:** The per-project config set `sitrep_repo` to a relative path whose git root was its parent, so
`git -C "$SITREP_REPO"` resolved to the parent repo and paths needed to be absolutized. Separately, an untracked
local agent-config file at the repo root sat outside the close-artifact allowlist, which literally says any dirty path
stops `start`.

**Root cause:** Bootstrap assumes `SITREP_REPO` is an absolute path equal to the git toplevel; the rollover allowlist
has no exemption for untracked, non-sitrep local config.

**Suggested fix:** Resolve `SITREP_REPO` to an absolute path in Step 0. In the rollover dirty-path check, ignore
untracked files that are not close artifacts and never stage them, rather than stopping `start`.
